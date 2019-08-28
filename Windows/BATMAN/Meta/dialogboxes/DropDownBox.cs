using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;


namespace RobvanderWoude
{
	class DropDownBox
	{
		public static string progver = "1.16";
		public static bool returnindex0 = false;
		public static bool returnindex1 = false;

		[STAThread]
		static int Main( string[] args )
		{
			#region Initialize Variables

			const int defaultheight = 90;
			const int defaultwidth = 200;

			char delimiter = ';';
			List<string> namedargs = new List<string>( );
			List<string> unnamedargs = new List<string>( );
			string file = String.Empty;
			string list = String.Empty;
			string cancelcaption = "&Cancel";
			string okcaption = "&OK";
			string localizationstring = String.Empty;
			string prompt = String.Empty;
			string selectedText = String.Empty;
			string title = String.Format( "DropDownBox,  Version {0}", progver );
			bool delimiterset = false;
			bool heightset = false;
			bool iconset = false;
			bool indexset = false;
			bool localizedcaptionset = false;
			bool monospaced = false;
			bool skipfirstitem = false;
			bool sortlist = false;
			bool tablengthset = false;
			bool topmost = true;
			bool widthset = false;
			int height = defaultheight;
			int icon = 23;
			int selectedindex = 0;
			int tablength = 4;
			int width = defaultwidth;

			bool isredirected = Console.IsInputRedirected; // Requires .NET Framework 4.5
			bool listset = isredirected;
			int redirectnum = ( isredirected ? 1 : 0 );
			int arguments = args.Length + redirectnum;

			#endregion Initialize Variables

				
			#region Command Line Parsing

			if ( arguments == 0 )
			{
				return ShowHelp( );
			}

			if ( arguments > 13 )
			{
				return ShowHelp( "Too many command line arguments" );
			}

			// Split up named and unnamed arguments
			foreach ( string arg in args )
			{
				if ( arg == "/?" )
				{
					return ShowHelp( );
				}
				if ( arg[0] == '/' )
				{
					namedargs.Add( arg );
				}
				else
				{
					unnamedargs.Add( arg );
				}
			}

			// Read Standard Input if the list is redirected
			if ( isredirected )
			{
				try
				{
					string delim = delimiter.ToString( );
					list = String.Join( delim, Console.In.ReadToEnd( ).Split( "\n\r".ToCharArray( ), StringSplitOptions.RemoveEmptyEntries ) );
					// Trim list items, remove empty ones
					string pattern = "\\s*" + delim + "+\\s*";
					list = Regex.Replace( list, pattern, delim );
				}
				catch ( Exception e )
				{
					return ShowHelp( e.Message );
				}
			}

			// First, validate the named arguments
			#region Named Arguments

			foreach ( string arg in namedargs )
			{
				if ( arg.Length < 3 && arg.ToUpper( ) != "/K" && arg.ToUpper( ) != "/L" && arg.ToUpper( ) != "/S" )
				{
					return ShowHelp( "Invalid command line switch {0} or missing value", arg );
				}
				if ( arg.ToUpper( ) == "/K" )
				{
					if ( skipfirstitem )
					{
						return ShowHelp( "Duplicate command line switch /K" );
					}
					skipfirstitem = true;
				}
				else if ( arg.ToUpper( ) == "/L" )
				{
					if ( localizedcaptionset )
					{
						return ShowHelp( "Duplicate command line switch /L" );
					}
					localizedcaptionset = true;
				}
				else if ( arg.ToUpper( ) == "/S" )
				{
					if ( sortlist )
					{
						return ShowHelp( "Duplicate command line switch /S" );
					}
					sortlist = true;
				}
				else
				{
					switch ( arg.Substring( 0, 3 ).ToUpper( ) )
					{
						case "/C:":
							if ( iconset )
							{
								return ShowHelp( "Duplicate command line switch /D" );
							}
							try
							{
								icon = Convert.ToInt32( arg.Substring( 3 ) );
							}
							catch ( Exception )
							{
								return ShowHelp( "Invalid icon index: {0}", arg.Substring( 3 ) );
							}
							iconset = true;
							break;
						case "/D:":
							if ( delimiterset )
							{
								return ShowHelp( "Duplicate command line switch /D" );
							}
							string test = arg.Substring( 3 );
							if ( test.Length == 1 )
							{
								delimiter = test[0];
							}
							else if ( test.Length == 3 && ( ( test[0] == '"' && test[2] == '"' ) || ( test[0] == '\'' && test[2] == '\'' ) ) )
							{
								delimiter = test[1];
							}
							else
							{
								return ShowHelp( String.Format( "Invalid delimiter specified \"{0}\"", arg ) );
							}
							break;
						case "/F:":
							if ( listset )
							{
								return ShowHelp( "Duplicate command line switch /F" );
							}
							file = arg.Substring( 3 );
							if ( String.IsNullOrEmpty( file ) || !File.Exists( file ) )
							{
								return ShowHelp( "List file not found: \"{0}\"", file );
							}
							else
							{
								try
								{
									string delim = delimiter.ToString( );
									list = String.Join( delim, File.ReadLines( file ) );
									string pattern = delim + "{2,}";
									// Remove empty list items
									Regex.Replace( list, pattern, delim );
								}
								catch ( Exception e )
								{
									return ShowHelp( e.Message );
								}
							}
							listset = true;
							break;
						case "/H:":
							if ( heightset )
							{
								return ShowHelp( "Duplicate command line switch /H" );
							}
							try
							{
								height = Convert.ToInt32( arg.Substring( 3 ) );
								if ( height < defaultheight || height > Screen.PrimaryScreen.Bounds.Height )
								{
									return ShowHelp( String.Format( "Height {0} outside allowed range of {1}..{2}", arg.Substring( 3 ), defaultheight, Screen.PrimaryScreen.Bounds.Height ) );
								}
							}
							catch ( Exception e )
							{
								return ShowHelp( String.Format( "Invalid height \"{0}\": {1}", arg.Substring( 3 ), e.Message ) );
							}
							heightset = true;
							break;
						case "/I:":
							if ( indexset )
							{
								return ShowHelp( "Duplicate command line switch /I" );
							}
							try
							{
								selectedindex = Convert.ToInt32( arg.Substring( 3 ) );
							}
							catch ( Exception e )
							{
								return ShowHelp( String.Format( "Invalid index value \"{0}\": {1}", arg, e.Message ) );
							}
							break;
						case "/L:":
							if ( localizedcaptionset )
							{
								return ShowHelp( "Duplicate command line switch /L" );
							}
							localizedcaptionset = true;
							localizationstring = arg.Substring( 3 );
							string localizationpattern = "(;|^)(OK|Cancel)=[^\\\"';]+(;|$)";
							foreach ( string substring in localizationstring.Split( ";".ToCharArray( ), StringSplitOptions.RemoveEmptyEntries ) )
							{
								if ( !Regex.IsMatch( substring, localizationpattern, RegexOptions.IgnoreCase ) )
								{
									return ShowHelp( "Invalid value for /L switch: \"{1}\"", localizationstring );
								}
							}
							break;
						case "/MF":
							if ( monospaced )
							{
								return ShowHelp( "Duplicate command line switch /MF" );
							}
							monospaced = true;
							break;
						case "/NM":
							if ( !topmost )
							{
								return ShowHelp( "Duplicate command line switch /NM" );
							}
							topmost = false;
							break;
						case "/R0":
						case "/RO":
							if ( returnindex0 || returnindex1 )
							{
								return ShowHelp( "Duplicate command line switch /R0, /R1, /RI and/or /RO" );
							}
							returnindex0 = true;
							break;
						case "/R1":
						case "/RI":
							if ( returnindex0 || returnindex1 )
							{
								return ShowHelp( "Duplicate command line switch /R0, /R1, /RI and/or /RO" );
							}
							returnindex1 = true;
							break;
						case "/T:":
							if ( tablengthset )
							{
								return ShowHelp( "Duplicate command line switch /T" );
							}
							try
							{
								tablength = Convert.ToInt32( arg.Substring( 3 ) );
								if ( tablength < 4 || tablength > 16 )
								{
									return ShowHelp( String.Format( "Tab length {0} outside allowed range of {1}..{2}", arg.Substring( 3 ), 4, 16 ) );
								}
							}
							catch ( Exception e )
							{
								return ShowHelp( String.Format( "Invalid tab length \"{0}\": {1}", arg.Substring( 3 ), e.Message ) );
							}
							tablengthset = true;
							break;
						case "/W:":
							if ( widthset )
							{
								return ShowHelp( "Duplicate command line switch /W" );
							}
							try
							{
								width = Convert.ToInt32( arg.Substring( 3 ) );
								if ( width < defaultwidth || width > Screen.PrimaryScreen.Bounds.Width )
								{
									return ShowHelp( String.Format( "Width {0} outside allowed range of {1}..{2}", arg.Substring( 3 ), defaultwidth, Screen.PrimaryScreen.Bounds.Width ) );
								}
							}
							catch ( Exception e )
							{
								return ShowHelp( String.Format( "Invalid width \"{0}\": {1}", arg.Substring( 3 ), e.Message ) );
							}
							widthset = true;
							break;
						default:
							return ShowHelp( String.Format( "Invalid command line switch \"{0}\"", arg ) );
					}
				}
			}

			#endregion Named Arguments


			// Next, validate unnamed arguments
			#region Unnamed Arguments

			if ( listset ) // This check is the reason why named arguments had to be validated before unnamed ones: /F switch changes the meaning of unnamed arguments
			{
				switch ( unnamedargs.Count )
				{
					case 0:
						break;
					case 1:
						prompt = unnamedargs[0];
						break;
					case 2:
						prompt = unnamedargs[0];
						title = unnamedargs[1];
						break;
					case 3:
						return ShowHelp( "Invalid command line argument: {0}", unnamedargs[2] );
					default:
						unnamedargs.RemoveRange( 0, 2 );
						return ShowHelp( "Invalid command line arguments: {0}", String.Join( ", ", unnamedargs ) );
				}
			}
			else
			{
				switch ( unnamedargs.Count )
				{
					case 0:
						break;
					case 1:
						list = unnamedargs[0];
						listset = true;
						break;
					case 2:
						list = unnamedargs[0];
						prompt = unnamedargs[1];
						listset = true;
						break;
					case 3:
						list = unnamedargs[0];
						prompt = unnamedargs[1];
						title = unnamedargs[2];
						listset = true;
						break;
					case 4:
						return ShowHelp( "Invalid command line argument: {0}", unnamedargs[3] );
					default:
						unnamedargs.RemoveRange( 0, 3 );
						return ShowHelp( "Invalid command line arguments: {0}", String.Join( ", ", unnamedargs ) );
				}
			}

			#endregion Unnamed Arguments


			// List is mandatory
			if ( !listset )
			{
				return ShowHelp( "No list specified" );
			}

			// Validate selected index
			int listrange = list.Split( delimiter ).Length - 1;
			if ( selectedindex < 0 || selectedindex > listrange )
			{
				return ShowHelp( String.Format( "Selected index ({0}) outside list range (0..{0})", selectedindex, listrange ) );
			}

			#endregion Command Line Parsing


			#region Set Localized Captions

			if ( localizedcaptionset )
			{
				cancelcaption = Load( "user32.dll", 801, cancelcaption );
				okcaption = Load( "user32.dll", 800, okcaption );

				if ( !String.IsNullOrWhiteSpace( localizationstring ) )
				{
					string[] locstrings = localizationstring.Split( ";".ToCharArray( ) );
					foreach ( string locstring in locstrings )
					{
						string key = locstring.Substring( 0, locstring.IndexOf( '=' ) );
						string val = locstring.Substring( Math.Min( locstring.IndexOf( '=' ) + 1, locstring.Length - 1 ) );
						if ( !String.IsNullOrWhiteSpace( val ) )
						{
							switch ( key.ToUpper( ) )
							{
								case "OK":
									okcaption = val;
									break;
								case "CANCEL":
									cancelcaption = val;
									break;
								default:
									return ShowHelp( "Invalid localization key \"{0}\"", key );
							}
						}
					}
				}
			}

			#endregion Set Localized Captions


			#region Build Form

			// Inspired by code by Gorkem Gencay on StackOverflow.com:
			// http://stackoverflow.com/questions/97097/what-is-the-c-sharp-version-of-vb-nets-inputdialog#17546909

			Form dropdownForm = new Form( );
			Size size = new Size( width, height );
			dropdownForm.FormBorderStyle = FormBorderStyle.FixedDialog;
			dropdownForm.MaximizeBox = false;
			dropdownForm.MinimizeBox = false;
			dropdownForm.StartPosition = FormStartPosition.CenterParent;
			dropdownForm.ClientSize = size;
			dropdownForm.Text = title;
			dropdownForm.Icon = IconExtractor.Extract( "shell32.dll", icon, true );

			if ( !String.IsNullOrWhiteSpace( prompt ) )
			{
				Label labelPrompt = new Label( );
				labelPrompt.Size = new Size( size.Width - 20, 20 );
				labelPrompt.Location = new Point( 10, 10 );
				// Replace tabs with spaces
				if ( prompt.IndexOf( "\\t", StringComparison.Ordinal ) > -1 )
				{
					string tab = new String( ' ', tablength );
					// First split the prompt on newlines
					string[] prompt2 = prompt.Split( new string[] { "\\n" }, StringSplitOptions.None );
					for ( int i = 0; i < prompt2.Length; i++ )
					{
						if ( prompt2[i].IndexOf( "\\t", StringComparison.Ordinal ) > -1 )
						{
							// Slit each "sub-line" of the prompt on tabs
							string[] prompt3 = prompt2[i].Split( new string[] { "\\t" }, StringSplitOptions.None );
							// Each substring before a tab gets n spaces attached, and then is cut off at the highest possible length which is a multiple of n
							for ( int j = 0; j < prompt3.Length - 1; j++ )
							{
								prompt3[j] += tab;
								int length = prompt3[j].Length;
								length /= tablength;
								length *= tablength;
								prompt3[j] = prompt3[j].Substring( 0, length );
							}
							prompt2[i] = String.Join( "", prompt3 );
						}
					}
					prompt = String.Join( "\n", prompt2 );
				}
				labelPrompt.Text = prompt.Replace( "\\n", "\n" ).Replace( "\\r", "\r" );
				if ( !heightset )
				{
					// Add 20 to window height to allow space for prompt
					size = new Size( size.Width, size.Height + 20 );
					dropdownForm.ClientSize = size;
				}
				labelPrompt.Size = new Size( size.Width - 20, size.Height - 90 );
				if ( monospaced )
				{
					labelPrompt.Font = new Font( FontFamily.GenericMonospace, labelPrompt.Font.Size );
				}
				dropdownForm.Controls.Add( labelPrompt );
			}

			ComboBox combobox;
			combobox = new ComboBox( );
			combobox.Size = new Size( size.Width - 20, 25 );
			combobox.Location = new Point( 10, size.Height - 70 );
			combobox.AutoCompleteMode = AutoCompleteMode.Append;
			combobox.AutoCompleteSource = AutoCompleteSource.ListItems;
			combobox.DropDownStyle = ComboBoxStyle.DropDownList;
			dropdownForm.Controls.Add( combobox );

			Button okButton = new Button( );
			okButton.DialogResult = DialogResult.OK;
			okButton.Name = "okButton";
			okButton.Size = new Size( 80, 25 );
			okButton.Text = okcaption;
			okButton.Location = new Point( size.Width / 2 - 10 - 80, size.Height - 35 );
			dropdownForm.Controls.Add( okButton );

			Button cancelButton = new Button( );
			cancelButton.DialogResult = DialogResult.Cancel;
			cancelButton.Name = "cancelButton";
			cancelButton.Size = new Size( 80, 25 );
			cancelButton.Text = cancelcaption;
			cancelButton.Location = new Point( size.Width / 2 + 10, size.Height - 35 );
			dropdownForm.Controls.Add( cancelButton );

			dropdownForm.AcceptButton = okButton;  // OK on Enter
			dropdownForm.CancelButton = cancelButton; // Cancel on Esc
			dropdownForm.Activate( );

			#endregion Build Form


			#region Populate List

			// Populate the dropdown list
			List<string> listitems = list.Split( delimiter ).ToList<string>( );
			if ( skipfirstitem )
			{
				listitems.RemoveAt( 0 );
			}
			if ( sortlist )
			{
				listitems.Sort( );
			}
			foreach ( string item in listitems )
			{
				combobox.Items.Add( item );
			}
			// Preselect an item
			combobox.SelectedIndex = selectedindex;

			#endregion Populate List


			dropdownForm.TopMost = topmost;
			DialogResult result = dropdownForm.ShowDialog( );
			if ( result == DialogResult.OK )
			{
				selectedText = combobox.SelectedItem.ToString( );
				Console.WriteLine( selectedText );
				if ( returnindex0 )
				{
					// With /RO: return code equals selected index for "OK", or -1 for (command line) errors or "Cancel".
					return combobox.SelectedIndex;
				}
				else if ( returnindex1 )
				{
					// With /RI: return code equals selected index + 1 for "OK", or 0 for (command line) errors or "Cancel".
					return combobox.SelectedIndex + 1;
				}
				else
				{
					// Default: return code 0 for "OK", 1 for (command line) errors, 2 for "Cancel".
					return 0;
				}
			}
			else
			{
				// Cancelled
				if ( returnindex0 )
				{
					// With /RO: return code equals selected index for "OK", or -1 for (command line) errors or "Cancel".
					return -1;
				}
				else if ( returnindex1 )
				{
					// With /RI: return code equals selected index + 1 for "OK", or 0 for (command line) errors or "Cancel".
					return 0;
				}
				else
				{
					// Default: return code 0 for "OK", 1 for (command line) errors, 2 for "Cancel".
					return 2;
				}
			}
		}


		#region Error handling

		public static int ShowHelp( params string[] errmsg )
		{
			#region Help Text

			/*
			DropDownBox,  Version 1.15
			Batch tool to present a DropDown dialog and return the selected item

			Usage:    DROPDOWNBOX     "list"  [ "prompt"  [ "title" ] ]  [ options ]

			   or:    DROPDOWNBOX     /F:"listfile"  [ "prompt"  [ "title" ] ]  [ options ]

			   or:    listcommand  |  DROPDOWNBOX  [ "prompt"  [ "title" ] ]  [ options ]

			Where:    "list"          is the list of items to populate the dropdown control
			          "listcommand"   is a command whose standard output is used as a list
			                          of items to populate the dropdown control
			          "prompt"        is the optional text above the dropdown control
			                          (default: none)
			          "title"         is the window title
			                          (default: "DropDownBox,  Version 1.10")

			Options:  /C:index        use iCon at index from shell32.dll (default: 23)
			          /D:"delimiter"  sets the Delimiter character for "list"
			                          (default: semicolon)
			          /F:"listfile"   use list from text File (one list item per line)
			          /H:height       sets the Height of the input box
			                          (default: 90; minimum: 90; maximum: screen height)
			          /I:index        sets the zero based Index of the preselected item
			                          (default: 0)
			          /K              sKip first item of list (e.g. a header line)
			          /L[:"captions"] Localize or customize button captions
			                          (e.g. /L:"OK=Why Not?;Cancel=No Way!")
			          /MF             use Monospaced Font in prompt (default: proportional)
			          /NM             make dialog Non-Modal (default: Modal, i.e. on top)
			          /RI or /R1      Return code equals selected Index + 1, or 0 on
			                          (command line) errors or if "Cancel" was clicked
			                          (default: 0 on "OK", 1 on error, 2 on "Cancel")
			          /RO or /R0      Return code equals selected 0-based index, or -1 on
			                          (command line) errors or if "Cancel" was clicked
			                          (default: 0 on "OK", 1 on error, 2 on "Cancel")
			          /S              Sort list (default: unsorted)
			          /T:tablength    sets the number of spaces for Tabs in prompt
			                          (4..16; default: 4)
			          /W:width        sets the Width of the input box
			                          (default: 200; minimum: 200; maximum: screen width)

			Notes:    The selected item text is written to Standard Out if "OK" is clicked,
			          otherwise an empty string is returned.
			          Use either "list" or /F:"listfile" or "listcommand".
			          Linefeeds (\n), tabs (\t) and doublequotes (\") are allowed in the
			          prompt text (but not in the title); with tabs, /MF is recommended.
			          If specified without captions, switch /L forces localized button
			          captions (e.g. "Cancel" button caption is "Annuleren" on Dutch
			          systems); if only a single custom caption is specified, the other
			          one is localized (e.g. with /L:"OK=Gaan" on Dutch systems, "OK"
			          button caption is "Gaan", "Cancel" button caption is "Annuleren").
			          Return code 0 for "OK", 1 for (command line) errors, 2 for "Cancel".
			          With /RI return code equals selected index + 1, or 0 for "Cancel".
			          With /RO return code equals selected index or -1 for "Cancel".
			          Command line switches /RI and /RO are mutually exclusive.

			Credits:  On-the-fly form based on code by Gorkem Gencay on StackOverflow:
			          http://stackoverflow.com/questions/97097#17546909
			          Code to retrieve localized button captions by Martin Stoeckli:
			          http://martinstoeckli.ch/csharp/csharp.html#windows_text_resources
			          Code to extract icons from Shell32.dll by Thomas Levesque:
			          http://stackoverflow.com/questions/6873026

			Written by Rob van der Woude
			http://www.robvanderwoude.com
			*/

			#endregion Help Text


			#region Error Message

			if ( errmsg.Length > 0 )
			{
				List<string> errargs = new List<string>( errmsg );
				errargs.RemoveAt( 0 );
				Console.Error.WriteLine( );
				Console.ForegroundColor = ConsoleColor.Red;
				Console.Error.Write( "ERROR:\t" );
				Console.ForegroundColor = ConsoleColor.White;
				Console.Error.WriteLine( errmsg[0], errargs.ToArray( ) );
				Console.ResetColor( );
			}

			#endregion Error Message


			#region Show Help Text

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "DropDownBox,  Version {0}", progver );

			Console.Error.WriteLine( "Batch tool to present a DropDown dialog and return the selected item" );

			Console.Error.WriteLine( );

			Console.Error.Write( "Usage:    " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "DROPDOWNBOX     \"list\"  [ \"prompt\"  [ \"title\" ] ]  [ options ]" );
			Console.ResetColor( );

			Console.Error.WriteLine( );

			Console.Error.Write( "   or:    " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "DROPDOWNBOX     /F:\"listfile\"  [ \"prompt\"  [ \"title\" ] ]  [ options ]" );
			Console.ResetColor( );

			Console.Error.WriteLine( );

			Console.Error.Write( "   or:    " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "listcommand  |  DROPDOWNBOX  [ \"prompt\"  [ \"title\" ] ]  [ options ]" );
			Console.ResetColor( );

			Console.Error.WriteLine( );

			Console.Error.Write( "Where:    " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"list\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( "          is the list of items to populate the dropdown control" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          \"listcommand\"" );
			Console.ResetColor( );
			Console.Error.Write( "   is a " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "command" );
			Console.ResetColor( );
			Console.Error.Write( " whose standard output is used as a " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "list" );
			Console.ResetColor( );

			Console.Error.WriteLine( "                          of items to populate the dropdown control" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          \"prompt\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( "        is the optional text above the dropdown control" );

			Console.Error.WriteLine( "                          (default: none)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          \"title\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( "         is the window title" );

			Console.Error.WriteLine( "                          (default: \"DropDownBox,  Version {0}\")", progver );

			Console.Error.WriteLine( );

			Console.Error.Write( "Options:  " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/C:index" );
			Console.ResetColor( );
			Console.Error.Write( "        use i" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "C" );
			Console.ResetColor( );
			Console.Error.Write( "on at " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "index" );
			Console.ResetColor( );
			Console.Error.WriteLine( " from shell32.dll (default: 23)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /D:\"delimiter\"" );
			Console.ResetColor( );
			Console.Error.Write( "  sets the " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "D" );
			Console.ResetColor( );
			Console.Error.Write( "elimiter character for " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "\"list\"" );
			Console.ResetColor( );

			Console.Error.WriteLine( "                          (default: semicolon)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /F:\"listfile\"" );
			Console.ResetColor( );
			Console.Error.Write( "   use list from text " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "F" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ile (one list item per line)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /H:height" );
			Console.ResetColor( );
			Console.Error.Write( "       sets the " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "H" );
			Console.ResetColor( );
			Console.Error.WriteLine( "eight of the input box" );

			Console.Error.WriteLine( "                          (default: 90; minimum: 90; maximum: screen height)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /I:index" );
			Console.ResetColor( );
			Console.Error.Write( "        sets the zero based " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "I" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ndex of the preselected item" );

			Console.Error.WriteLine( "                          (default: 0)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /K" );
			Console.ResetColor( );
			Console.Error.Write( "              s" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "K" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ip first item of list (e.g. a header line)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /L[:\"captions\"] L" );
			Console.ResetColor( );
			Console.Error.Write( "ocalize or customize button " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "captions" );
			Console.ResetColor( );

			Console.Error.Write( "                          (e.g. " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/L:\"OK=Why Not?;Cancel=No Way!\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( ")" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /MF" );
			Console.ResetColor( );
			Console.Error.Write( "             use " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "M" );
			Console.ResetColor( );
			Console.Error.Write( "onospaced " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "F" );
			Console.ResetColor( );
			Console.Error.Write( "ont in " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "prompt" );
			Console.ResetColor( );
			Console.Error.WriteLine( " (default: proportional)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /NM" );
			Console.ResetColor( );
			Console.Error.Write( "             make dialog " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "N" );
			Console.ResetColor( );
			Console.Error.Write( "on-" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "M" );
			Console.ResetColor( );
			Console.Error.WriteLine( "odal (default: modal, i.e. on top)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /RI" );
			Console.ResetColor( );
			Console.Error.Write( " or " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/R1      R" );
			Console.ResetColor( );
			Console.Error.Write( "eturn code equals selected " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "I" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ndex + 1, or 0 on" );

			Console.Error.WriteLine( "                          (command line) errors or if \"Cancel\" was clicked" );

			Console.Error.WriteLine( "                          (default: 0 on \"OK\", 1 on error, 2 on \"Cancel\")" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /RO" );
			Console.ResetColor( );
			Console.Error.Write( " or " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/R0      R" );
			Console.ResetColor( );
			Console.Error.Write( "eturn code equals selected " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "0" );
			Console.ResetColor( );
			Console.Error.WriteLine( "-based index, or -1 on" );

			Console.Error.WriteLine( "                          (command line) errors or if \"Cancel\" was clicked" );

			Console.Error.WriteLine( "                          (default: 0 on \"OK\", 1 on error, 2 on \"Cancel\")" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /S              S" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ort list (default: unsorted)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /T:tablength" );
			Console.ResetColor( );
			Console.Error.Write( "    sets the number of spaces for " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "T" );
			Console.ResetColor( );
			Console.Error.Write( "abs in " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "prompt" );
			Console.ResetColor( );

			Console.Error.WriteLine( "                          (4..16; default: 4)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /W:width" );
			Console.ResetColor( );
			Console.Error.Write( "        sets the " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "W" );
			Console.ResetColor( );
			Console.Error.WriteLine( "idth of the input box" );

			Console.Error.WriteLine( "                          (default: 200; minimum: 200; maximum: screen width)" );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Notes:    The selected item text is written to Standard Out if \"OK\" is clicked," );

			Console.Error.WriteLine( "          otherwise an empty string is returned." );

			Console.Error.Write( "          Use either " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"list\"" );
			Console.ResetColor( );
			Console.Error.Write( " or " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/F:\"listfile\"" );
			Console.ResetColor( );
			Console.Error.Write( " or " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"listcommand\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( "." );

			Console.Error.WriteLine( "          Linefeeds (\\n), tabs (\\t) and doublequotes (\\\") are allowed in the" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          prompt" );
			Console.ResetColor( );
			Console.Error.Write( " text (but not in the " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "title" );
			Console.ResetColor( );
			Console.Error.Write( "); with tabs, " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/MF" );
			Console.ResetColor( );
			Console.Error.WriteLine( " is recommended." );

			Console.Error.Write( "          If specified without " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "captions" );
			Console.ResetColor( );
			Console.Error.Write( ", switch " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/L" );
			Console.ResetColor( );
			Console.Error.WriteLine( " forces localized button" );

			Console.Error.WriteLine( "          captions (e.g. \"Cancel\" button caption is \"Annuleren\" on Dutch" );

			Console.Error.WriteLine( "          systems); if only a single custom caption is specified, the other" );

			Console.Error.Write( "          one is localized (e.g. with " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/L:\"OK=Gaan\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( " on Dutch systems, \"OK\"" );

			Console.Error.WriteLine( "          button caption is \"Gaan\", \"Cancel\" button caption is \"Annuleren\")." );

			Console.Error.WriteLine( "          Return code 0 for \"OK\", 1 for (command line) errors, 2 for \"Cancel\"." );

			Console.Error.Write( "          With " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/RI" );
			Console.ResetColor( );
			Console.Error.WriteLine( " return code equals selected index + 1, or 0 for \"Cancel\"." );

			Console.Error.Write( "          With " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/RO" );
			Console.ResetColor( );
			Console.Error.WriteLine( " return code equals selected index, or -1 for \"Cancel\"." );

			Console.Error.Write( "          Command line switches " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/RI" );
			Console.ResetColor( );
			Console.Error.Write( " and " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/RO" );
			Console.ResetColor( );
			Console.Error.WriteLine( " are mutually exclusive." );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Credits:  On-the-fly form based on code by Gorkem Gencay on StackOverflow:" );

			Console.ForegroundColor = ConsoleColor.DarkGray;
			Console.Error.WriteLine( "          http://stackoverflow.com/questions/17546909" );
			Console.ResetColor( );

			Console.Error.WriteLine( "          Code to retrieve localized button captions by Martin Stoeckli:" );

			Console.ForegroundColor = ConsoleColor.DarkGray;
			Console.Error.WriteLine( "          http://martinstoeckli.ch/csharp/csharp.html#windows_text_resources" );
			Console.ResetColor( );

			Console.Error.WriteLine( "          Code to extract icons from Shell32.dll by Thomas Levesque:" );

			Console.ForegroundColor = ConsoleColor.DarkGray;
			Console.Error.WriteLine( "          http://stackoverflow.com/questions/6873026" );
			Console.ResetColor( );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Written by Rob van der Woude" );

			Console.Error.WriteLine( "http://www.robvanderwoude.com" );
			
			#endregion Show Help Text


			if ( returnindex0 )
			{
				// With /RO: return code equals selected index for "OK", or -1 for (command line) errors or "Cancel".
				return -1;
			}
			else if ( returnindex1 )
			{
				// With /RI: return code equals selected index + 1 for "OK", or 0 for (command line) errors or "Cancel".
				return 0;
			}
			else
			{
				// Default: return code 0 for "OK", 1 for (command line) errors, 2 for "Cancel".
				return 1;
			}
		}

		#endregion Error handling


		#region Get Localized Captions

		// Code to retrieve localized captions by Martin Stoeckli
		// http://martinstoeckli.ch/csharp/csharp.html#windows_text_resources

		/// <summary>
		/// Searches for a text resource in a Windows library.
		/// Sometimes, using the existing Windows resources, you can make your code
		/// language independent and you don't have to care about translation problems.
		/// </summary>
		/// <example>
		///   btnCancel.Text = Load("user32.dll", 801, "Cancel");
		///   btnYes.Text = Load("user32.dll", 805, "Yes");
		/// </example>
		/// <param name="libraryName">Name of the windows library like "user32.dll"
		/// or "shell32.dll"</param>
		/// <param name="ident">Id of the string resource.</param>
		/// <param name="defaultText">Return this text, if the resource string could
		/// not be found.</param>
		/// <returns>Requested string if the resource was found,
		/// otherwise the <paramref name="defaultText"/></returns>
		public static string Load( string libraryName, UInt32 ident, string defaultText )
		{
			IntPtr libraryHandle = GetModuleHandle( libraryName );
			if ( libraryHandle != IntPtr.Zero )
			{
				StringBuilder sb = new StringBuilder( 1024 );
				int size = LoadString( libraryHandle, ident, sb, 1024 );
				if ( size > 0 )
					return sb.ToString( );
			}
			return defaultText;
		}

		[DllImport( "kernel32.dll", CharSet = CharSet.Auto )]
		private static extern IntPtr GetModuleHandle( string lpModuleName );

		[DllImport( "user32.dll", CharSet = CharSet.Auto )]
		private static extern int LoadString( IntPtr hInstance, UInt32 uID, StringBuilder lpBuffer, Int32 nBufferMax );

		#endregion Get Localized Captions


		#region Extract Icons

		// Code to extract icons from Shell32.dll by Thomas Levesque
		// http://stackoverflow.com/questions/6873026

		public class IconExtractor
		{

			public static Icon Extract( string file, int number, bool largeIcon )
			{
				IntPtr large;
				IntPtr small;
				ExtractIconEx( file, number, out large, out small, 1 );
				try
				{
					return Icon.FromHandle( largeIcon ? large : small );
				}
				catch
				{
					return null;
				}

			}

			[DllImport( "Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall )]
			private static extern int ExtractIconEx( string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons );
		}

		#endregion Extract Icons
	}
}
