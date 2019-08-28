using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;


namespace RobvanderWoude
{
	class RadioButtonBox
	{
		public static string progver = "1.01";


		#region Global Variables

		public static bool returnindex0 = false;
		public static bool returnindex1 = false;
		public const int defaultwindowheight = 320;
		public const int defaultwindowwidth = 480;
		public const int minimumwindowheight = 90;
		public const int minimumwindowwidth = 200;
		public static int screenheight = Screen.PrimaryScreen.WorkingArea.Height;
		public static int screenwidth = Screen.PrimaryScreen.WorkingArea.Width;
		public static int maximumwindowheight = screenheight;
		public static int maximumwindowwidth = screenwidth;
		public static int borderX = 0;
		public static int borderY = 0;

		#endregion Global Variables


		[STAThread]
		static int Main( string[] args )
		{
			#region Initialize Variables

			char delimiter = ';';
			List<string> namedargs = new List<string>( );
			List<string> unnamedargs = new List<string>( );
			string file = String.Empty;
			string list = String.Empty;
			string cancelcaption = "&Cancel";
			string okcaption = "&OK";
			string localizationstring = String.Empty;
			string prompt = String.Empty;
			string selectedtext = String.Empty;
			string title = String.Format( "RadioButtonBox,  Version {0}", progver );
			bool deduplist = false;
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
			double rbsafetyfactor = 1.05;
			int columns = 0;
			int defaultindex = 0;
			int icon = 23;
			int promptheight = 20;
			int rc = 0;
			int rows = 0;
			int tablength = 4;
			int windowheight = defaultwindowheight;
			int windowwidth = defaultwindowwidth;
			Label labelPrompt = new Label( );

			bool isredirected = Console.IsInputRedirected; // Requires .NET Framework 4.5
			bool listset = isredirected;
			int redirectnum = ( isredirected ? 1 : 0 );
			int arguments = args.Length + redirectnum;

			int[] borders = BorderDimensions( );
			borderX = borders[0];
			borderY = borders[1];
			maximumwindowheight = screenheight - borderY;
			maximumwindowwidth = screenwidth - borderX;

			#endregion Initialize Variables


			#region Command Line Parsing

			if ( arguments == 0 )
			{
				return ShowHelp( );
			}

			if ( arguments > 16 )
			{
				return ShowHelp( "Too many command line arguments" );
			}

			// Split up named and unnamed arguments
			foreach ( string arg in args )
			{
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
				if ( arg.Length > 1 && !arg.Contains( ":" ) && !arg.Contains( "=" ) )
				{
					#region Boolean Named Arguments

					string key = arg.ToUpper( );
					switch ( key )
					{
						case "/?":
						case "/HELP":
							return ShowHelp( );
						case "/??":
						case "/???":
						case "/A":
						case "/ALIAS":
						case "/ALIASES":
							return ShowAliases( );
						case "/DE":
						case "/DEDUP":
							if ( deduplist )
							{
								return ShowHelp( "Duplicate command line switch /DE" );
							}
							deduplist = true;
							break;
						case "/K":
						case "/SKIP":
						case "/SKIPFIRST":
						case "/SKIPFIRSTITEM":
							if ( skipfirstitem )
							{
								return ShowHelp( "Duplicate command line switch /K" );
							}
							skipfirstitem = true;
							break;
						case "/L":
						case "/LOCALIZED":
						case "/LOCALIZEDCAPTIONS":
							if ( localizedcaptionset )
							{
								return ShowHelp( "Duplicate command line switch /L" );
							}
							localizedcaptionset = true;
							break;
						case "/MF":
						case "/MONO":
						case "/MONOSPACED":
						case "/MONOSPACEDFONT":
							if ( monospaced )
							{
								return ShowHelp( "Duplicate command line switch /MF" );
							}
							monospaced = true;
							break;
						case "/NM":
						case "/NONMODAL":
						case "/NON-MODAL":
							if ( !topmost )
							{
								return ShowHelp( "Duplicate command line switch /NM" );
							}
							topmost = false;
							break;
						case "/RC0":
						case "/RETURN0BASEDINDEX":
							if ( returnindex0 || returnindex1 )
							{
								return ShowHelp( "Duplicate command line switch /RC0 and/or /RC1" );
							}
							returnindex0 = true;
							break;
						case "/RC1":
						case "/RETURN1BASEDINDEX":
							if ( returnindex0 || returnindex1 )
							{
								return ShowHelp( "Duplicate command line switch /RC0 and/or /RC1" );
							}
							returnindex1 = true;
							break;
						case "/S":
						case "/SORT":
						case "/SORTLIST":
							if ( sortlist )
							{
								return ShowHelp( "Duplicate command line switch /S" );
							}
							sortlist = true;
							break;
						default:
							return ShowHelp( "Invalid command line switch {0} or missing value", arg );
					}
					
					#endregion Boolean Named Arguments
				}
				else if ( arg.Length > 3 && ( arg.Contains( ":" ) || arg.Contains( "=" ) ) )
				{
					#region Key/Value Named Arguments

					string key = arg.ToUpper( ).Substring( 0, arg.IndexOfAny( ":=".ToCharArray( ) ) );
					string val = arg.Substring( arg.IndexOfAny( ":=".ToCharArray( ) ) + 1 );
					switch ( key )
					{
						case "/C":
						case "/COL":
						case "/COLS":
						case "/COLUMNS":
							if ( columns != 0 )
							{
								return ShowHelp( "Duplicate command line switch /C" );
							}
							try
							{
								columns = Convert.ToInt32( val );
								if ( columns < 0 )
								{
									return ShowHelp( "Columns must be a positive integer" );
								}
							}
							catch ( Exception )
							{
								return ShowHelp( "Invalid columns value \"{0}\"", arg );
							}
							break;
						case "/D":
						case "/DELIMITER":
							if ( delimiterset )
							{
								return ShowHelp( "Duplicate command line switch /D" );
							}
							if ( val.Length == 1 )
							{
								delimiter = val[0];
							}
							else if ( val.Length == 3 && ( ( val[0] == '"' && val[2] == '"' ) || ( val[0] == '\'' && val[2] == '\'' ) ) )
							{
								delimiter = val[1];
							}
							else
							{
								return ShowHelp( String.Format( "Invalid delimiter specified \"{0}\"", arg ) );
							}
							break;
						case "/F":
						case "/FILE":
							if ( listset )
							{
								return ShowHelp( "Duplicate command line switch /F" );
							}
							file = val;
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
						case "/H":
						case "/HEIGHT":
							if ( heightset )
							{
								return ShowHelp( "Duplicate command line switch /H" );
							}
							try
							{
								windowheight = Convert.ToInt32( val );
								if ( windowheight < minimumwindowheight || windowheight > maximumwindowheight )
								{
									return ShowHelp( String.Format( "Height {0} outside allowed range of {1}..{2}", val, minimumwindowheight, maximumwindowheight ) );
								}
							}
							catch ( Exception e )
							{
								return ShowHelp( String.Format( "Invalid height \"{0}\": {1}", val, e.Message ) );
							}
							heightset = true;
							break;
						case "/I":
						case "/ICON":
							if ( iconset )
							{
								return ShowHelp( "Duplicate command line switch /I" );
							}
							try
							{
								icon = Convert.ToInt32( val );
							}
							catch ( Exception )
							{
								return ShowHelp( "Invalid icon index: {0}", val );
							}
							iconset = true;
							break;
						case "/L":
						case "/LOCALIZED":
						case "/LOCALIZEDCAPTIONS":
							if ( localizedcaptionset )
							{
								return ShowHelp( "Duplicate command line switch /L" );
							}
							localizedcaptionset = true;
							localizationstring = val;
							string localizationpattern = "(;|^)(OK|Cancel)=[^\\\"';]+(;|$)";
							foreach ( string substring in localizationstring.Split( ";".ToCharArray( ), StringSplitOptions.RemoveEmptyEntries ) )
							{
								if ( !Regex.IsMatch( substring, localizationpattern, RegexOptions.IgnoreCase ) )
								{
									return ShowHelp( "Invalid value for /L switch: \"{1}\"", localizationstring );
								}
							}
							break;
						case "/P":
						case "/DEFAULT":
						case "/DEFAULTINDEX":
						case "/PRE":
						case "/PRESELECTED":
						case "/PRESELECTEDINTEX":
							if ( indexset )
							{
								return ShowHelp( "Duplicate command line switch /P" );
							}
							try
							{
								defaultindex = Convert.ToInt32( val );
							}
							catch ( Exception e )
							{
								return ShowHelp( String.Format( "Invalid index value \"{0}\": {1}", arg, e.Message ) );
							}
							break;
						case "/R":
						case "/ROWS":
							if ( rows != 0 )
							{
								return ShowHelp( "Duplicate command line switch /R" );
							}
							try
							{
								rows = Convert.ToInt32( val );
								if ( rows < 0 )
								{
									return ShowHelp( "Rows must be a positive integer" );
								}
							}
							catch ( Exception )
							{
								return ShowHelp( "Invalid rows value \"{0}\"", arg );
							}
							break;
						case "/T:":
						case "/TAB":
						case "/TABLENGTH":
							if ( tablengthset )
							{
								return ShowHelp( "Duplicate command line switch /T" );
							}
							try
							{
								tablength = Convert.ToInt32( val );
								if ( tablength < 4 || tablength > 16 )
								{
									return ShowHelp( String.Format( "Tab length {0} outside allowed range of {1}..{2}", val, 4, 16 ) );
								}
							}
							catch ( Exception e )
							{
								return ShowHelp( String.Format( "Invalid tab length \"{0}\": {1}", val, e.Message ) );
							}
							tablengthset = true;
							break;
						case "/W":
						case "/WIDTH":
							if ( widthset )
							{
								return ShowHelp( "Duplicate command line switch /W" );
							}
							try
							{
								windowwidth = Convert.ToInt32( val );
								if ( windowwidth < minimumwindowwidth || windowwidth > maximumwindowwidth )
								{
									return ShowHelp( String.Format( "Width {0} outside allowed range of {1}..{2}", val, minimumwindowwidth, maximumwindowwidth ) );
								}
							}
							catch ( Exception e )
							{
								return ShowHelp( String.Format( "Invalid width \"{0}\": {1}", val, e.Message ) );
							}
							widthset = true;
							break;
						default:
							return ShowHelp( String.Format( "Invalid command line switch \"{0}\"", arg ) );
					}

					#endregion Key/Value Named Arguments

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


			#region Validate Specified Values and Combinations

			if ( !listset )
			{
				return ShowHelp( "Mandatory list not specified" );
			}

			if ( rows * columns != 0 )
			{
				return ShowHelp( "You may specify the number of either columns or rows, but not both" );
			}

			int listrange = list.Split( new char[] { delimiter }, StringSplitOptions.RemoveEmptyEntries ).Length - 1;
			if ( defaultindex < 0 || defaultindex > listrange )
			{
				return ShowHelp( String.Format( "Preselected index ({0}) outside list range (0..{1})", defaultindex, listrange ) );
			}

			#endregion Validate Specified Values and Combinations

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


			#region Parse List

			List<string> listitems = new List<string>( list.Split( delimiter.ToString( ).ToCharArray( ), StringSplitOptions.RemoveEmptyEntries ) );
			if ( skipfirstitem )
			{
				listitems.RemoveAt( 0 );
			}
			for ( int i = 0; i < listitems.Count; i++ )
			{
				listitems[i] = listitems[i].Trim( );
			}
			if ( deduplist )
			{
				List<string> deduped = new List<string>( );
				foreach ( string key in listitems )
				{
					if ( !deduped.Contains( key ) )
					{
						deduped.Add( key );
					}
				}
				listitems = deduped;
			}
			if ( sortlist )
			{
				listitems.Sort( StringComparer.OrdinalIgnoreCase );
			}

			#endregion Parse List


			#region Main Form

			Form radiobuttonform = new Form( );
			radiobuttonform.FormBorderStyle = FormBorderStyle.FixedDialog;
			radiobuttonform.MaximizeBox = false;
			radiobuttonform.MinimizeBox = false;
			radiobuttonform.StartPosition = FormStartPosition.CenterParent;
			radiobuttonform.Text = title;
			radiobuttonform.Icon = IconExtractor.Extract( "shell32.dll", icon, true );

			#endregion Main Form


			#region Initial Sizes

			int horizontalmargin = 10;
			int verticalmargin = 10;
			int promptwidth = 0;
			int rbtextheight = 0; // radiobutton text height
			int rbtextwidth = 0; // radiobutton text width
			int rbwidth = 15; // radiobutton width without text
			int buttonheight = 25;
			int buttonwidth = 80;

			#endregion Initial Sizes


			#region Prompt

			if ( String.IsNullOrWhiteSpace( prompt ) )
			{
				promptheight = -1 * verticalmargin;
			}
			else
			{
				if ( monospaced )
				{
					labelPrompt.Font = new Font( FontFamily.GenericMonospace, labelPrompt.Font.Size );
				}

				// Calculate required height for single prompt line
				promptheight = TextRenderer.MeasureText( "Test", labelPrompt.Font ).Height;

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
							// Split each "sub-line" of the prompt on tabs
							string[] prompt3 = prompt2[i].Split( new string[] { "\\t" }, StringSplitOptions.None );
							// Each substring before a tab gets n spaces attached, and then is shortened to the greatest possible multiple of n
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
				prompt = prompt.Replace( "\\n", "\n" ).Replace( "\\r", "\r" );
				labelPrompt.Text = prompt;
				string[] lines = prompt.Split( "\n".ToCharArray( ) );
				int promptlines = lines.Length;

				foreach ( string line in lines )
				{
					promptwidth = Math.Max( promptwidth, TextRenderer.MeasureText( line, labelPrompt.Font ).Width );
				}

				// Calculate required height for multiple line prompt
				promptheight = promptlines * promptheight;
			}

			#endregion Prompt


			#region Radio Buttons

			List<RadioButton> radiobuttons = new List<RadioButton>( );
			for ( int i = 0; i < listitems.Count; i++ )
			{
				RadioButton radiobutton = new RadioButton( );
				radiobutton.Text = listitems[i];
				radiobutton.Checked = ( defaultindex == i );
				rbtextwidth = Math.Max( rbtextwidth, Convert.ToInt32( TextRenderer.MeasureText( listitems[i], radiobutton.Font ).Width * rbsafetyfactor ) );
				rbtextheight = Math.Max( rbtextheight, Convert.ToInt32( TextRenderer.MeasureText( listitems[i], radiobutton.Font ).Height * rbsafetyfactor ) );
				radiobuttons.Add( radiobutton );
			}

			GroupBox rbgroup = new GroupBox( );

			#endregion Radio Buttons


			#region Buttons

			Button okButton = new Button( );
			okButton.DialogResult = DialogResult.OK;
			okButton.Name = "okButton";
			okButton.Text = okcaption;

			Button cancelButton = new Button( );
			cancelButton.DialogResult = DialogResult.Cancel;
			cancelButton.Name = "cancelButton";
			cancelButton.Text = cancelcaption;

			#endregion Buttons


			#region Calculate Window Layout

			if ( rows > 0 )
			{
				rows = Math.Min( rows, listitems.Count );
				columns = (int) Math.Floor( (decimal) ( listitems.Count + rows - 1 ) / rows );
			}
			else if ( columns > 0 )
			{
				columns = Math.Min( columns, listitems.Count );
				rows = (int) Math.Floor( (decimal) ( listitems.Count + columns - 1 ) / columns );
			}
			else
			{
				columns = 1;
				rows = listitems.Count;
			}

			int rbgroupwidth = 0;
			int rbgroupheight = 0;
			int rowheight = 0;
			int colwidth = 0;

			if ( widthset )
			{
				rbgroupwidth = windowwidth - 2 * horizontalmargin;
				colwidth = (int) Math.Floor( (decimal) ( rbgroupwidth - horizontalmargin - columns * ( rbwidth + horizontalmargin ) ) / columns );
			}
			else
			{
				colwidth = rbtextwidth + rbwidth;
				rbgroupwidth = Math.Max( minimumwindowwidth - 2 * horizontalmargin, columns * ( colwidth + horizontalmargin ) + 2 * horizontalmargin );
				windowwidth = Math.Max( minimumwindowwidth, rbgroupwidth + 2 * horizontalmargin );
			}

			if ( heightset )
			{
				rbgroupheight = windowheight - promptheight - buttonheight - 4 * verticalmargin;
				rowheight = (int) Math.Floor( (decimal) ( rbgroupheight - 2 * verticalmargin ) / rows );
			}
			else
			{
				rowheight = rbtextheight + verticalmargin;
				windowheight = Math.Max( minimumwindowheight, 6 * verticalmargin + promptheight + buttonheight + rows * rowheight );
				rbgroupheight = rows * rowheight + 2 * verticalmargin;
			}

			#endregion Calculate Window Layout


			#region Check Available Group Box Space

			if ( rbgroupheight / rows < rowheight || rbgroupwidth / columns < colwidth )
			{
				return ShowHelp( "Window size too small to display all radio buttons;\n\tincrease window size, reduce or remove prompt,\n\tand/or change number of rows and columns" );
			}

			#endregion Check Available Group Box Space


			#region Build Form

			Size windowsize = new Size( windowwidth, windowheight );
			radiobuttonform.ClientSize = windowsize;

			if ( !String.IsNullOrWhiteSpace( prompt ) )
			{
				labelPrompt.Size = new Size( windowwidth - 2 * horizontalmargin, promptheight );
				labelPrompt.Location = new Point( horizontalmargin, verticalmargin );
				radiobuttonform.Controls.Add( labelPrompt );
			}

			rbgroup.Size = new Size( rbgroupwidth, rbgroupheight );
			rbgroup.Location = new Point( horizontalmargin, promptheight + 2 * verticalmargin );

			foreach ( RadioButton radiobutton in radiobuttons )
			{
				rbgroup.Controls.Add( radiobutton );
			}
			radiobuttonform.Controls.Add( rbgroup );

			for ( int row = 0; row < rows; row++ )
			{
				for ( int column = 0; column < columns; column++ )
				{
					int index = row * columns + column;
					if ( index < radiobuttons.Count )
					{
						int x = Convert.ToInt32( horizontalmargin + column * ( colwidth + horizontalmargin ) );
						int y = Convert.ToInt32( verticalmargin + row * rowheight );
						radiobuttons[index].Size = new Size( colwidth + horizontalmargin, rowheight );
						radiobuttons[index].Location = new Point( x, y );
					}
				}
			}

			okButton.Size = new Size( buttonwidth, buttonheight );
			okButton.Location = new Point( windowwidth / 2 - horizontalmargin - buttonwidth, windowheight - buttonheight - verticalmargin );
			radiobuttonform.Controls.Add( okButton );

			cancelButton.Size = new Size( buttonwidth, buttonheight );
			cancelButton.Location = new Point( windowwidth / 2 + horizontalmargin, windowheight - buttonheight - verticalmargin );
			radiobuttonform.Controls.Add( cancelButton );

			radiobuttonform.AcceptButton = okButton;  // OK on Enter
			radiobuttonform.CancelButton = cancelButton; // Cancel on Esc

			#endregion Build Form


			#region Show Dialog

			radiobuttonform.TopMost = topmost;
			DialogResult result = radiobuttonform.ShowDialog( );
			if ( result == DialogResult.OK )
			{
				foreach ( RadioButton rb in rbgroup.Controls )
				{
					if ( rb.Checked )
					{
						selectedtext = rb.Text;
						defaultindex = listitems.IndexOf( selectedtext );
						break;
					}
				}

				// Display selected text
				Console.WriteLine( selectedtext );

				if ( returnindex0 )
				{
					// With /RO: return code equals selected index for "OK", or -1 for (command line) errors or "Cancel".
					rc = defaultindex;
				}
				else if ( returnindex1 )
				{
					// With /RI: return code equals selected index + 1 for "OK", or 0 for (command line) errors or "Cancel".
					rc = defaultindex + 1;
				}
				else
				{
					// Default: return code 0 for "OK", 1 for (command line) errors, 2 for "Cancel".
					rc = 0;
				}
			}
			else
			{
				// Cancelled
				if ( returnindex0 )
				{
					// With /RO: return code equals selected index for "OK", or -1 for (command line) errors or "Cancel".
					rc = -1;
				}
				else if ( returnindex1 )
				{
					// With /RI: return code equals selected index + 1 for "OK", or 0 for (command line) errors or "Cancel".
					rc = 0;
				}
				else
				{
					// Default: return code 0 for "OK", 1 for (command line) errors, 2 for "Cancel".
					rc = 2;
				}
			}

			#endregion Show Dialog


			return rc;
		}

		#region Error handling

		public static int ShowAliases()
		{
			int rc = ShowHelp( );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "Switch\tAlias(es)" );

			Console.Error.WriteLine( "======\t=========" );

			Console.Error.WriteLine( );

			Console.Error.Write( "/?\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/HELP" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/A\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/??, /???, /ALIAS or /ALIASES" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/C\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/COL, /COLS or /COLUMNS" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/D\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/DELIMITER" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/DE\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/DEDUP" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/F\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/FILE" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/H\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/HEIGHT" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/I\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/ICON" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/K\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/SKIP, /SKIPFIRST or /SKIPFIRSTITEM" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/L\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/LOCALIZED or /LOCALIZEDCAPTIONS" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/MF\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/MONO, /MONOSPACED or /MONOSPACEDFONT" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/NM\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/NONMODAL or /NON-MODAL" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/P\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/DEFAULT, /DEFAULTINDEX, /PRE, /PRESELECTED or /PRESELECTEDINDEX" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/R\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/ROWS" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/RC0\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/RETURN0BASEDINDEX" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/RC1\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/RETURN1BASEDINDEX" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/S\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/SORT or /SORTLIST" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/T\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/TAB or /TABLENGTH" );

			Console.Error.WriteLine( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/W\t" );
			Console.ResetColor( );
			Console.Error.WriteLine( "/WIDTH" );

			Console.Error.WriteLine( );

			return rc;
		}


		public static int ShowHelp( params string[] errmsg )
		{
			#region Help Text

			/*
			RadioButtonBox,  Version 1.00
			Batch tool to present a Radio Button dialog and return the selected item

			Usage:   RADIOBUTTONBOX   "list"  [ "prompt"  [ "title" ] ]  [ options ]

			   or:   RADIOBUTTONBOX   /F:"listfile"  [ "prompt"  [ "title" ] ]  [ options ]

			   or:   listcommand  |  RADIOBUTTONBOX  [ "prompt"  [ "title" ] ]  [ options ]

			Where:   "list"          a list of items to populate the radio buttons group
			         "listcommand"   is a command whose standard output is used as a list
			                         of items to populate the radio buttons group
			         "prompt"        is the optional text above the radio buttons group
			                         (default: none)
			         "title"         is the window title
			                         (default: "RadioButtonBox,  Version 1.00")
			Options: /A              show Aliases for command line switches (see Notes)
			         /C:columns      sets then number of Columns for the radio button group
			                         (default: 1)
			         /D:"delimiter"  sets the Delimiter character for "list"
			                         (default: semicolon)
			         /DE             DEdup: remove duplicates from "list"
			         /F:"listfile"   use list from text File (one list item per line)
			         /H:height       sets the window Height (default: autosized to make
			                         content fit; minimum: 90; maximum: screen height - 68)
			         /I:index        use Icon at index from shell32.dll (default: 23)
			         /K              sKip first item of list (e.g. a header line)
			         /L[:"captions"] Localize or customize button captions
			                         (e.g. /L:"OK=Why Not?;Cancel=No Way!")
			         /MF             use Monospaced Font in prompt (default: proportional)
			         /NM             make dialog Non-Modal (default: Modal, i.e. on top)
			         /P:index        sets the zero based index of the Preselected item
			                         (default: 0)
			         /R:rows         sets then number of Rows for the radio button group
			                         (default: one row per list item)
			         /RC0            Return Code equals selected 0-based index, or -1 on
			                         (command line) errors or if "Cancel" was clicked
			                         (default: 0 on "OK", 1 on error, 2 on "Cancel")
			         /RC1            Return Code equals selected 1-based index, or 0 on
			                         (command line) errors or if "Cancel" was clicked
			                         (default: 0 on "OK", 1 on error, 2 on "Cancel")
			         /S              Sort list (default: unsorted)
			         /T:tablength    sets the number of spaces for Tabs in prompt
			                         (4..16; default: 4)
			         /W:width        sets the window Width (default: autosized to make
			                         content fit; minimum: 200; maximum: screen width - 16)

			Notes:   The selected item text is written to Standard Out if "OK" is clicked,
			         otherwise an empty string is returned.
			         Most command line switches have one or more aliases, e.g. instead
			         of /R:5 you can use /ROWS:5 to make your batch files more readable;
			         use command line switch /A to get a list of all available aliases.
			         Use either "list" or /F:"listfile" or "listcommand".
			         Linefeeds (\n), tabs (\t) and doublequotes (\") are allowed in the
			         prompt text (but not in the title); with tabs, /MF is recommended.
			         To get a custom title without prompt, use " " for prompt.
			         If specified without captions, switch /L forces localized button
			         captions (e.g. "Cancel" button caption is "Annuleren" on Dutch
			         systems); if only a single custom caption is specified, the other
			         one is localized (e.g. with /L:"OK=Gaan" on Dutch systems, "OK"
			         button caption is "Gaan", "Cancel" button caption is "Annuleren").
			         Return code 0 for "OK", 1 for (command line) errors, 2 for "Cancel".
			         With /RC0 return code equals selected index or -1 for "Cancel".
			         With /RC1 return code equals selected index + 1, or 0 for "Cancel".
			         Command line switches /RC0 and /RC1 are mutually exclusive.

			Credits: On-the-fly form based on code by Gorkem Gencay on StackOverflow:
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

			Console.Error.WriteLine( "RadioButtonBox,  Version {0}", progver );

			Console.Error.WriteLine( "Batch tool to present a Radio Button dialog and return the selected item" );

			Console.Error.WriteLine( );

			Console.Error.Write( "Usage:   " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "RADIOBUTTONBOX   \"list\"  [ \"prompt\"  [ \"title\" ] ]  [ options ]" );
			Console.ResetColor( );

			Console.Error.WriteLine( );

			Console.Error.Write( "   or:   " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "RADIOBUTTONBOX   /F:\"listfile\"  [ \"prompt\"  [ \"title\" ] ]  [ options ]" );
			Console.ResetColor( );

			Console.Error.WriteLine( );

			Console.Error.Write( "   or:   " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "listcommand  |  RADIOBUTTONBOX  [ \"prompt\"  [ \"title\" ] ]  [ options ]" );
			Console.ResetColor( );

			Console.Error.WriteLine( );

			Console.Error.Write( "Where:   " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"list\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( "          a list of items to populate the radio button group" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         \"listcommand\"" );
			Console.ResetColor( );
			Console.Error.Write( "   is a " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "command" );
			Console.ResetColor( );
			Console.Error.Write( " whose standard output is used as a " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "list" );
			Console.ResetColor( );

			Console.Error.WriteLine( "                         of items to populate the radio button group" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         \"prompt\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( "        is the optional text above the radio button group" );

			Console.Error.WriteLine( "                         (default: none)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         \"title\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( "         is the window title" );

			Console.Error.WriteLine( "                         (default: \"RadioButtonBox,  Version {0}\")", progver );

			Console.Error.Write( "Options: " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/A" );
			Console.ResetColor( );
			Console.Error.Write( "              show " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "A" );
			Console.ResetColor( );
			Console.Error.WriteLine( "liases for command line switches (see Notes)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /C:columns" );
			Console.ResetColor( );
			Console.Error.Write( "      sets then number of " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "C" );
			Console.ResetColor( );
			Console.Error.WriteLine( "olumns for the radio button group" );

			Console.Error.WriteLine( "                         (default: 1)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /D:\"delimiter\"" );
			Console.ResetColor( );
			Console.Error.Write( "  sets the " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "D" );
			Console.ResetColor( );
			Console.Error.Write( "elimiter character for " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "\"list\"" );
			Console.ResetColor( );

			Console.Error.WriteLine( "                         (default: semicolon)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /DE             DE" );
			Console.ResetColor( );
			Console.Error.Write( "dup: remove duplicates from " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "\"list\"" );
			Console.ResetColor( );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /F:\"listfile\"" );
			Console.ResetColor( );
			Console.Error.Write( "   use list from text " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "F" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ile (one list item per line)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /H:height" );
			Console.ResetColor( );
			Console.Error.Write( "       sets the window " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "H" );
			Console.ResetColor( );
			Console.Error.WriteLine( "eight (default: autosized to make" );

			Console.Error.WriteLine( "                         content fit; minimum: {0}; maximum: screen height - {1})", minimumwindowheight, borderY );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /I:index" );
			Console.ResetColor( );
			Console.Error.Write( "        use " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "I" );
			Console.ResetColor( );
			Console.Error.Write( "con at " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "index" );
			Console.ResetColor( );
			Console.Error.WriteLine( " from shell32.dll (default: 23)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /K" );
			Console.ResetColor( );
			Console.Error.Write( "              s" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "K" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ip first item of list (e.g. a header line)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /L[:\"captions\"] L" );
			Console.ResetColor( );
			Console.Error.Write( "ocalize or customize button " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "captions" );
			Console.ResetColor( );

			Console.Error.Write( "                         (e.g. " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/L:\"OK=Why Not?;Cancel=No Way!\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( ")" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /MF" );
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
			Console.Error.Write( "         /NM" );
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
			Console.Error.Write( "         /P:index" );
			Console.ResetColor( );
			Console.Error.Write( "        sets the zero based " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "index" );
			Console.ResetColor( );
			Console.Error.Write( " of the " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "P" );
			Console.ResetColor( );
			Console.Error.WriteLine( "reselected item" );

			Console.Error.WriteLine( "                         (default: 0)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /R:rows" );
			Console.ResetColor( );
			Console.Error.Write( "         sets then number of " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "R" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ows for the radio button group" );

			Console.Error.WriteLine( "                         (default: one row per list item)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /RC0            R" );
			Console.ResetColor( );
			Console.Error.Write( "eturn " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "C" );
			Console.ResetColor( );
			Console.Error.Write( "ode equals selected " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "0" );
			Console.ResetColor( );
			Console.Error.WriteLine( "-based index, or -1 on" );

			Console.Error.WriteLine( "                         (command line) errors or if \"Cancel\" was clicked" );

			Console.Error.WriteLine( "                         (default: 0 on \"OK\", 1 on error, 2 on \"Cancel\")" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /RC1            R" );
			Console.ResetColor( );
			Console.Error.Write( "eturn " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "C" );
			Console.ResetColor( );
			Console.Error.Write( "ode equals selected " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "1" );
			Console.ResetColor( );
			Console.Error.WriteLine( "-based index, or 0 on" );

			Console.Error.WriteLine( "                         (command line) errors or if \"Cancel\" was clicked" );

			Console.Error.WriteLine( "                         (default: 0 on \"OK\", 1 on error, 2 on \"Cancel\")" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /S              S" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ort list (default: unsorted)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /T:tablength" );
			Console.ResetColor( );
			Console.Error.Write( "    sets the number of spaces for " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "T" );
			Console.ResetColor( );
			Console.Error.Write( "abs in " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "prompt" );
			Console.ResetColor( );

			Console.Error.WriteLine( "                         (4..16; default: 4)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         /W:width" );
			Console.ResetColor( );
			Console.Error.Write( "        sets the window " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "W" );
			Console.ResetColor( );
			Console.Error.WriteLine( "idth (default: autosized to make" );

			Console.Error.WriteLine( "                         content fit; minimum: {0}; maximum: screen width - {1})", minimumwindowwidth, borderX );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Notes:   The selected item text is written to Standard Out if \"OK\" is clicked," );

			Console.Error.WriteLine( "         otherwise an empty string is returned." );

			Console.Error.WriteLine( "         Most command line switches have one or more aliases, e.g. instead" );

			Console.Error.Write( "         of " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/R:5" );
			Console.ResetColor( );
			Console.Error.Write( " you can use " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/ROWS:5" );
			Console.ResetColor( );
			Console.Error.WriteLine( " to make your batch files more readable;" );

			Console.Error.Write( "         use command line switch " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/A" );
			Console.ResetColor( );
			Console.Error.WriteLine( " to get a list of all available aliases." );

			Console.Error.Write( "         Use either " );
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

			Console.Error.WriteLine( "         Linefeeds (\\n), tabs (\\t) and doublequotes (\\\") are allowed in the" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "         prompt" );
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

			Console.Error.WriteLine( "         To get a custom title without prompt, use \" \" for prompt." );

			Console.Error.Write( "         If specified without " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "captions" );
			Console.ResetColor( );
			Console.Error.Write( ", switch " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/L" );
			Console.ResetColor( );
			Console.Error.WriteLine( " forces localized button" );

			Console.Error.WriteLine( "         captions (e.g. \"Cancel\" button caption is \"Annuleren\" on Dutch" );

			Console.Error.WriteLine( "         systems); if only a single custom caption is specified, the other" );

			Console.Error.Write( "         one is localized (e.g. with " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/L:\"OK=Gaan\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( " on Dutch systems, \"OK\"" );

			Console.Error.WriteLine( "         button caption is \"Gaan\", \"Cancel\" button caption is \"Annuleren\")." );

			Console.Error.WriteLine( "         Return code 0 for \"OK\", 1 for (command line) errors, 2 for \"Cancel\"." );

			Console.Error.Write( "         With " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/RC0" );
			Console.ResetColor( );
			Console.Error.WriteLine( " return code equals selected index, or -1 for \"Cancel\"." );

			Console.Error.Write( "         With " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/RC1" );
			Console.ResetColor( );
			Console.Error.WriteLine( " return code equals selected index + 1, or 0 for \"Cancel\"." );

			Console.Error.Write( "         Command line switches " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/RC0" );
			Console.ResetColor( );
			Console.Error.Write( " and " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/RC1" );
			Console.ResetColor( );
			Console.Error.WriteLine( " are mutually exclusive." );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Credits: On-the-fly form based on code by Gorkem Gencay on StackOverflow:" );

			Console.ForegroundColor = ConsoleColor.DarkGray;
			Console.Error.WriteLine( "         http://stackoverflow.com/questions/17546909" );
			Console.ResetColor( );

			Console.Error.WriteLine( "         Code to retrieve localized button captions by Martin Stoeckli:" );

			Console.ForegroundColor = ConsoleColor.DarkGray;
			Console.Error.WriteLine( "         http://martinstoeckli.ch/csharp/csharp.html#windows_text_resources" );
			Console.ResetColor( );

			Console.Error.WriteLine( "         Code to extract icons from Shell32.dll by Thomas Levesque:" );

			Console.ForegroundColor = ConsoleColor.DarkGray;
			Console.Error.WriteLine( "         http://stackoverflow.com/questions/6873026" );
			Console.ResetColor( );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Written by Rob van der Woude" );

			Console.Error.WriteLine( "http://www.robvanderwoude.com" );

			#endregion Show Help Text


			// Default: return code 0 for "OK", 1 for (command line) errors, 2 for "Cancel".
			int rc = 0;
			if ( returnindex0 )
			{
				// With /R0: return code equals selected index for "OK", or -1 for (command line) errors or "Cancel".
				rc = -1;
			}
			else if ( returnindex1 )
			{
				// With /R1: return code equals selected index + 1 for "OK", or 0 for (command line) errors or "Cancel".
				rc = 0;
			}

			return rc;
		}

		#endregion Error handling


		#region Get Window Border Dimensions

		public static int[] BorderDimensions( )
		{
			Form testform = new Form( );
			Size testsize = new Size( 300, 200 );
			testform.Size = testsize;
			int deltaX = testform.Size.Width - testform.ClientSize.Width + Screen.PrimaryScreen.Bounds.Width - Screen.PrimaryScreen.WorkingArea.Width;
			int deltaY = testform.Size.Height - testform.ClientSize.Height + Screen.PrimaryScreen.Bounds.Height - Screen.PrimaryScreen.WorkingArea.Height;
			testform.Dispose( );
			return new int[] { deltaX, deltaY };
		}

		#endregion Get Window Border Dimensions


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
