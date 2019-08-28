using System;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.Management;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;


namespace RobvanderWoude
{
	class PrinterSelectBox
	{
		public static string progver = "2.06";

		#region Global Variables

		public static ComboBox combobox;
		public static Label statusfield;
		public static Label typefield;
		public static Label wherefield;
		public static Label commentfield;
		public static List<string[]> localprinters = new List<string[]>( );
		public static List<string[]> networkprinters = new List<string[]>( );

		public const int defaultheight = 220;
		public const int defaultwidth = 400;

		#endregion Global Variables


		[STAThread]
		static int Main( string[] args )
		{
			try
			{
				// On-the fly form inspired by Gorkem Gencay's code on StackOverflow.com:
				// http://stackoverflow.com/questions/97097/what-is-the-c-sharp-version-of-vb-nets-inputdialog#17546909

				#region Initialize Variables
				
				string selected;
				string title = "Select Printer";
				bool titleset = false;
				string preselected = String.Empty;
				bool preselectedset = false;
				string cancelcaption = "&Cancel";
				string okcaption = "&OK";
				string printcaption = "&Print";
				bool printcaptionset = false;
				SortedList localprinternames = new SortedList( );
				SortedList networkprinternames = new SortedList( );
				bool localonly = false;
				bool networkonly = false;
				int height = defaultheight;
				int width = defaultwidth;
				string localizationstring = String.Empty;
				bool localizedcaptionset = false;
				string namecaption = "Name";
				string statuscaption = "Status";
				string typecaption = "Type";
				string wherecaption = "Where";
				string commentcaption = "Comment";

				#endregion Initialize Variables


				#region Populate Printers List

				QueryPrinters( );

				localprinternames.Clear( );
				foreach ( string[] prn in localprinters )
				{
					localprinternames.Add( prn[0], prn[5] );
					// Make the default printer the initial preselected printer in the dropdown list
					if ( prn[5] == "1" )
					{
						preselected = prn[0];
					}
				}

				networkprinternames.Clear( );
				foreach ( string[] prn in networkprinters )
				{
					networkprinternames.Add( prn[0], prn[5] );
					// Make the default printer the initial preselected printer in the dropdown list
					if ( prn[5] == "1" )
					{
						preselected = prn[0];
					}
				}

				#endregion Populate Printers List


				#region Parse Command Line

				if ( args.Length > 5 )
				{
					return ShowHelp( );
				}
				foreach ( string arg in args )
				{
					if ( arg == "/?" )
					{
						return ShowHelp( );
					}
				}

				if ( args.Length > 0 )
				{
					foreach ( string arg in args )
					{
						if ( arg.Length > 0 && arg[0] == '/' )
						{
							if ( arg.Length > 5 && arg.Substring( 0, 3 ).ToUpper( ) == "/H:" )
							{
								if ( height != defaultheight )
								{
									return ShowHelp( "Duplicate command line switch /H" );
								}
								try
								{
									height = Convert.ToInt32( arg.Substring( 3 ) );
								}
								catch ( Exception )
								{
									return ShowHelp( "Invalid height \"{0}\"", arg );
								}
								if ( height > Screen.PrimaryScreen.WorkingArea.Height || height < defaultheight )
								{
									return ShowHelp( "Window height must be in range {0}..{1}", defaultheight.ToString( ), Screen.PrimaryScreen.WorkingArea.Height.ToString( ) );
								}
							}
							else if ( arg.Length > 1 && arg.Substring( 0, 2 ).ToUpper( ) == "/L" )
							{
								if ( localizedcaptionset )
								{
									return ShowHelp( "Duplicate command line switch /L" );
								}
								localizedcaptionset = true;
								if ( arg.Length > 3 )
								{
									if ( arg[2] == ':' )
									{
										localizationstring = arg.Substring( 3 );
									}
									else
									{
										return ShowHelp( "Invalid command line switch {0}", arg );
									}
								}
							}
							else if ( arg.Length > 1 && arg.Substring( 0, 2 ).ToUpper( ) == "/N" )
							{
								if ( localonly )
								{
									return ShowHelp( "Duplicate command line switch /N" );
								}
								if ( networkonly )
								{
									return ShowHelp( "Command line switches /N and /O are mutually exclusive" );
								}
								networkonly = true;
								localonly = false;
							}
							else if ( arg.Length > 1 && arg.Substring( 0, 2 ).ToUpper( ) == "/O" )
							{
								if ( networkonly )
								{
									return ShowHelp( "Duplicate command line switch /O" );
								}
								if ( localonly )
								{
									return ShowHelp( "Command line switches /N and /O are mutually exclusive" );
								}
								networkonly = false;
								localonly = true;
							}
							else if ( arg.Length > 1 && arg.Substring( 0, 2 ).ToUpper( ) == "/P" )
							{
								if ( printcaptionset )
								{
									return ShowHelp( "Duplicate command line switch /P" );
								}
								printcaptionset = true;
								if ( arg.Length > 3 )
								{
									if ( arg[2] == ':' )
									{
										printcaption = arg.Substring( 3 );
									}
									else
									{
										return ShowHelp( "Invalid command line switch {0}", arg );
									}
								}
							}
							else if ( arg.Length > 5 && arg.Substring( 0, 3 ).ToUpper( ) == "/W:" )
							{
								if ( width != defaultwidth )
								{
									return ShowHelp( "Duplicate command line switch /W" );
								}
								try
								{
									width = Convert.ToInt32( arg.Substring( 3 ) );
								}
								catch ( Exception )
								{
									return ShowHelp( "Invalid width \"{0}\"", arg );
								}
								if ( width > Screen.PrimaryScreen.WorkingArea.Width || width < defaultwidth )
								{
									return ShowHelp( "Window width must be in range {0}..{1}", defaultwidth.ToString( ), Screen.PrimaryScreen.WorkingArea.Width.ToString( ) );
								}
							}
							else
							{
								return ShowHelp( "Invalid command line switch {0}", arg );
							}
						}
						else
						{
							if ( !titleset )
							{
								title = arg;
								titleset = true;
							}
							else if ( !preselectedset )
							{
								// Make the specified printer the selected one in the dropdown list
								if ( localprinternames.ContainsKey( arg ) )
								{
									preselected = arg;
								}
								else
								{
									string pattern = arg;
									bool match = false;
									foreach ( string printer in localprinternames.Keys )
									{
										if ( Regex.IsMatch( printer, pattern, RegexOptions.IgnoreCase ) )
										{
											match = true;
											preselected = printer;
											break; // Search no further after first match
										}
									}
									if ( !match )
									{
										return ShowHelp( "No printer name found matching \"{0}\"", preselected );
									}
								}
								preselectedset = true;
							}
							else if ( width == defaultwidth ) // For backwards compatibility only; use /W switch instead
							{
								try
								{
									width = Convert.ToInt32( arg );
								}
								catch ( Exception )
								{
									return ShowHelp( "Invalid width \"{0}\"", arg );
								}
							}
							else
							{
								return ShowHelp( "Invalid command line argument \"{0}\"", arg );
							}
						}
					}
				}

				if ( localonly && localprinters.Count == 0 )
				{
					return ShowHelp( "No local printers found" );
				}

				if ( networkonly && networkprinters.Count == 0 )
				{
					return ShowHelp( "No network printers found" );
				}

				#endregion Parse Command Line


				#region Set Localized Captions

				if ( localizedcaptionset )
				{
					cancelcaption = Load( "user32.dll", 801, cancelcaption );
					okcaption = Load( "user32.dll", 800, okcaption );
					if ( !String.IsNullOrWhiteSpace( localizationstring ) )
					{
						string pattern = @"^((Name|Status|Type|Where|Comment|OK|Cancel)=[^;\""]*;)*((Name|Status|Type|Where|Comment|OK|Cancel)=[^;\""]*);?$";
						Regex regex = new Regex( pattern, RegexOptions.IgnoreCase );
						if ( regex.IsMatch( localizationstring ) )
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
										case "NAME":
											namecaption = val;
											break;
										case "STATUS":
											statuscaption = val;
											break;
										case "TYPE":
											typecaption = val;
											break;
										case "WHERE":
											wherecaption = val;
											break;
										case "COMMENT":
											commentcaption = val;
											break;
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
						else
						{
							return ShowHelp( "Invalid localization string:\n\t{0}", localizationstring );
						}
					}
				}

				#endregion Set Localized Captions


				#region Build Form

				// Create the dialog box
				Form printerSelect = new Form( );
				Size size = new Size( width, height );
				printerSelect.FormBorderStyle = FormBorderStyle.FixedDialog;
				printerSelect.MaximizeBox = false;
				printerSelect.MinimizeBox = false;
				printerSelect.StartPosition = FormStartPosition.CenterParent;
				printerSelect.ClientSize = size;
				if ( printcaptionset && !titleset )
				{
					title = printcaption.Replace( "&", String.Empty );
				}
				printerSelect.Text = title;

				// Label "Name:" for printer name
				Label labelName = new Label( );
				labelName.Size = new Size( 70, 20 );
				labelName.Location = new Point( 10, 27 );
				labelName.Text = namecaption + ":";
				printerSelect.Controls.Add( labelName );

				// Dropdown list to contain available printer names
				combobox = new ComboBox( );
				combobox.Size = new Size( size.Width - 100, 25 );
				combobox.Location = new Point( 90, 25 );
				combobox.AutoCompleteMode = AutoCompleteMode.Append;
				combobox.AutoCompleteSource = AutoCompleteSource.ListItems;
				combobox.DropDownStyle = ComboBoxStyle.DropDownList;
				combobox.SelectedIndexChanged += new EventHandler( combobox_SelectedIndexChanged );
				printerSelect.Controls.Add( combobox );

				// Label "Status:" for selected printer's current status
				Label labelStatus = new Label( );
				labelStatus.Size = new Size( 70, 20 );
				labelStatus.Location = new Point( 10, 57 );
				labelStatus.Text = statuscaption + ":";
				printerSelect.Controls.Add( labelStatus );

				// Label to contain selected printer's current status
				statusfield = new Label( );
				statusfield.Size = new Size( size.Width - 10 - 80, 20 );
				statusfield.Location = new Point( 90, 57 );
				statusfield.Text = "Status Value";
				printerSelect.Controls.Add( statusfield );

				// Label "Type:" for selected printer's type description
				Label labelType = new Label( );
				labelType.Size = new Size( 70, 20 );
				labelType.Location = new Point( 10, 82 );
				labelType.Text = typecaption + ":";
				printerSelect.Controls.Add( labelType );

				// Label to contain selected printer's type description
				typefield = new Label( );
				typefield.Size = new Size( size.Width - 10 - 80, 20 );
				typefield.Location = new Point( 90, 82 );
				typefield.Text = "Type Value";
				printerSelect.Controls.Add( typefield );

				// Label "Where:" for selected printer's location or printer port
				Label labelWhere = new Label( );
				labelWhere.Size = new Size( 70, 20 );
				labelWhere.Location = new Point( 10, 107 );
				labelWhere.Text = wherecaption + ":";
				printerSelect.Controls.Add( labelWhere );

				// Label to contain selected printer's location or printer port
				wherefield = new Label( );
				wherefield.Size = new Size( size.Width - 10 - 80, 20 );
				wherefield.Location = new Point( 90, 107 );
				wherefield.Text = "Where Value";
				printerSelect.Controls.Add( wherefield );

				// Label "Comment:" for selected printer's optional comment line
				Label labelComment = new Label( );
				labelComment.Size = new Size( 70, 20 );
				labelComment.Location = new Point( 10, 132 );
				labelComment.Text = commentcaption + ":";
				printerSelect.Controls.Add( labelComment );

				// Label to contain selected printer's optional comment line
				commentfield = new Label( );
				commentfield.Size = new Size( size.Width - 10 - 80, 20 );
				commentfield.Location = new Point( 90, 132 );
				commentfield.Text = "Comment Value";
				printerSelect.Controls.Add( commentfield );

				Button okButton = new Button( );
				okButton.DialogResult = DialogResult.OK;
				okButton.Name = "okButton";
				okButton.Size = new Size( 80, 25 );
				if ( printcaptionset )
				{
					okButton.Text = printcaption;
				}
				else
				{
					okButton.Text = okcaption;
				}
				okButton.Location = new Point( size.Width / 2 - 10 - 80, 175 );
				printerSelect.Controls.Add( okButton );

				Button cancelButton = new Button( );
				cancelButton.DialogResult = DialogResult.Cancel;
				cancelButton.Name = "cancelButton";
				cancelButton.Size = new Size( 80, 25 );
				cancelButton.Text = cancelcaption;
				cancelButton.Location = new Point( size.Width / 2 + 10, 175 );
				printerSelect.Controls.Add( cancelButton );

				printerSelect.AcceptButton = okButton;  // OK on Enter
				printerSelect.CancelButton = cancelButton; // Cancel on Esc
				printerSelect.Activate( );

				#endregion Build Form


				#region Populate Dropdown with Local Printers

				int index = 0;
				if ( !networkonly )
				{
					foreach ( string prn in localprinternames.Keys )
					{
						combobox.Items.Add( prn );
						// Select the preselected printer if specified, or the default printer otherwise
						if ( prn.ToLower( ) == preselected.ToLower( ) )
						{
							combobox.SelectedIndex = index;
							foreach ( string[] printer in localprinters )
							{
								if ( printer[0].ToLower( ) == preselected.ToLower( ) )
								{
									statusfield.Text = printer[1];
									typefield.Text = printer[2];
									wherefield.Text = printer[3];
									commentfield.Text = printer[4];
								}
							}
						}
						index += 1;
					}
				}

				#endregion Populate Dropdown with Local Printers


				#region Populate Dropdown with Network Printers

				if ( !localonly )
				{
					foreach ( string prn in networkprinternames.Keys )
					{
						combobox.Items.Add( prn );
						// Select the preselected printer if specified, or the default printer otherwise
						if ( prn.ToLower( ) == preselected.ToLower( ) )
						{
							combobox.SelectedIndex = index;
							foreach ( string[] printer in networkprinters )
							{
								if ( printer[0].ToLower( ) == preselected.ToLower( ) )
								{
									statusfield.Text = printer[1];
									typefield.Text = printer[2];
									wherefield.Text = printer[3];
									commentfield.Text = printer[4];
								}
							}
						}
						index += 1;
					}
				}

				#endregion Populate Dropdown with Network Printers


				DialogResult result = printerSelect.ShowDialog( );
				if ( result == DialogResult.OK )
				{
					selected = combobox.SelectedItem.ToString( );
					Console.WriteLine( selected );
					return 0;
				}
				else
				{
					return 2;
				}
			}
			catch ( Exception e )
			{
				return ShowHelp( e.Message );
			}
		}


		public static void combobox_SelectedIndexChanged( object sender, EventArgs e )
		{
			string printername = combobox.Text;
			foreach ( string[] prn in localprinters )
			{
				if ( prn[0] == printername )
				{
					statusfield.Text = prn[1];
					typefield.Text = prn[2];
					wherefield.Text = prn[3];
					commentfield.Text = prn[4];
				}
			}
		}


		public static void QueryPrinters( )
		{
			localprinters.Clear( );
			networkprinters.Clear( );

			string query = "SELECT * FROM Win32_Printer";
			ManagementObjectSearcher searcher = new ManagementObjectSearcher( "root\\CIMV2", query );
			foreach ( ManagementObject queryObj in searcher.Get( ) )
			{
				string printer = (string) queryObj["DeviceID"];
				UInt32 printerstatus = Convert.ToUInt32( queryObj["ExtendedPrinterStatus"] );
				string printertype = (string) queryObj["DriverName"];
				string printerlocation = (string) queryObj["Location"];
				string printerport = (string) queryObj["PortName"];
				string printercomment = (string) queryObj["Comment"];
				bool isdefault = (bool) queryObj["Default"];
				bool islocal = (bool) queryObj["Local"];
				bool isnetwork = (bool) queryObj["Network"];
				string[] printerproperties = new string[6];
				printerproperties[0] = printer;
				printerproperties[1] = ( (WMIPrinterStatus) printerstatus ).ToString( );
				printerproperties[2] = printertype;
				if ( String.IsNullOrWhiteSpace( printerlocation ) )
				{
					printerproperties[3] = printerport;
				}
				else
				{
					printerproperties[3] = printerlocation;
				}
				printerproperties[4] = printercomment;
				printerproperties[5] = ( isdefault ? "1" : "0" );
				if ( islocal )
				{
					localprinters.Add( printerproperties );
				}
				else if ( isnetwork )
				{
					networkprinters.Add( printerproperties );
				}
			}
		}


		public static void UpdateFields( )
		{
			string printername = combobox.SelectedValue.ToString( );
			foreach ( string[] prn in localprinters )
			{
				if ( prn[0] == printername )
				{
					statusfield.Text = prn[1];
					typefield.Text = prn[2];
					wherefield.Text = prn[3];
					commentfield.Text = prn[4];
				}
			}
		}


		public static int ShowHelp( params string[] errmsg )
		{
			#region Help Text

			/*
			PrinterSelectBox,  Version 2.06
			Batch tool to present a Printer Select dialog and return the selected printer

			Usage:    PRINTERSELECTBOX  [ "title"  [ "selected" ] ]  [ options ]

			Where:    "title"     is the optional caption in the title bar
			          "selected"  is the optional selected printer, either its full name or
			                      a regular expression (default: the default printer name)
			
			Options:  /H:height   window Height (def: 220; min: 220; max: screen height)
			          /L[:string] Use Localized or custom captions (see Notes)
			          /N          list Network printers only (default: list all printers)
			          /O          list lOcal printers only   (default: list all printers)
			          /P[:text]   Alternative "OK" button caption "Print" or "text"
			          /W:width    window Width (default: 400; min: 400; max: screen width)

			Notes:    Use /L for Localized "OK" and "Cancel" button captions only.
			          Custom captions require a "localization string" in the format
			          /L:"key=value;key=value;..." e.g. for Dutch on English computers:
			          /L:"Name=Naam;Where=Lokatie;Comment=Opmerking;Cancel=Annuleren"
			          The name of the selected printer is written to Standard Out if the
			          "OK" button is clicked, otherwise an empty string is returned.
			          If "selected" is specified, the program will try an exact (literal)
			          match first; if no match is found, "selected" will be interpreted as
			          a regular expression, and the first match in the sorted printer list
			          will be used.
			          If no "title" is specified and /P is used, the alternative "OK"
			          button caption ("Print" or "text") will be used for "title" too.
			          Return code 0 for "OK", 1 for (command line) errors, 2 for "Cancel".

			Credits:  On-the-fly form based on code by Gorkem Gencay on StackOverflow:
			          http://stackoverflow.com/questions/97097
			          /what-is-the-c-sharp-version-of-vb-nets-inputdialog#17546909
			          Code to retrieve localized button captions by Martin Stoeckli:
			          http://martinstoeckli.ch/csharp/csharp.html#windows_text_resources

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


			#region Show help text

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "PrinterSelectBox,  Version {0}", progver );

			Console.Error.WriteLine( "Batch tool to present a Printer Select dialog and return the selected printer" );

			Console.Error.WriteLine( );

			Console.Error.Write( "Usage:    " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "PRINTERSELECTBOX  [ \"title\"  [ \"selected\" ] ]  [ options ]" );
			Console.ResetColor( );

			Console.Error.WriteLine( );

			Console.Error.Write( "Where:    " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"title\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( "     is the optional caption in the title bar" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          \"selected\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( "  is the optional selected printer, either its full name or" );

			Console.Error.WriteLine( "                      a regular expression (default: the default printer name)" );

			Console.Error.WriteLine( );

			Console.Error.Write( "Options:  " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/H:height" );
			Console.ResetColor( );
			Console.Error.Write( "   window " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "Height" );
			Console.ResetColor( );
			Console.Error.WriteLine( "(def: {0}; min: 220; max: screen height)", defaultheight );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /L[:string]" );
			Console.ResetColor( );
			Console.Error.Write( " Use " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "L" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ocalized or custom captions (see Notes)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /N" );
			Console.ResetColor( );
			Console.Error.Write( "          list " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "N" );
			Console.ResetColor( );
			Console.Error.WriteLine( "etwork printers only (default: list all printers)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /O" );
			Console.ResetColor( );
			Console.Error.Write( "          list l" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "O" );
			Console.ResetColor( );
			Console.Error.WriteLine( "cal printers only   (default: list all printers)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /P[:text]" );
			Console.ResetColor( );
			Console.Error.Write( "   Alternative \"OK\" button caption \"" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "P" );
			Console.ResetColor( );
			Console.Error.Write( "rint\" or \"" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "text" );
			Console.ResetColor( );
			Console.Error.WriteLine( "\"" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /W:width" );
			Console.ResetColor( );
			Console.Error.Write( "    window " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "Width" );
			Console.ResetColor( );
			Console.Error.WriteLine( " (default: {0}; min: 400; max: screen width)", defaultwidth );

			Console.Error.WriteLine( );

			Console.Error.Write( "Notes:    Use " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/L" );
			Console.ResetColor( );
			Console.Error.Write( " for " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "L" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ocalized \"OK\" and \"Cancel\" button captions only." );

			Console.Error.Write( "          Custom captions require a \"localization " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "string" );
			Console.ResetColor( );
			Console.Error.WriteLine( "\" in the format" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /L:\"key=value;key=value;...\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( " e.g. for Dutch on English computers:" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "          /L:\"Name=Naam;Where=Lokatie;Comment=Opmerking;Cancel=Annuleren\"" );
			Console.ResetColor( );

			Console.Error.WriteLine( "          The name of the selected printer is written to Standard Out if the" );

			Console.Error.WriteLine( "          \"OK\" button is clicked, otherwise an empty string is returned." );

			Console.Error.Write( "          If \"" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "selected" );
			Console.ResetColor( );
			Console.Error.WriteLine( "\" is specified, the program will try an exact (literal)" );

			Console.Error.Write( "          match first; if no match is found, \"" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "selected" );
			Console.ResetColor( );
			Console.Error.WriteLine( "\" will be interpreted as" );

			Console.Error.WriteLine( "          a regular expression, and the first match in the sorted printer list" );

			Console.Error.WriteLine( "          will be used." );

			Console.Error.Write( "          If no \"" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "title" );
			Console.ResetColor( );
			Console.Error.Write( "\" is specified and " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/P" );
			Console.ResetColor( );
			Console.Error.WriteLine( " is used, the alternative \"OK\"" );

			Console.Error.Write( "          button caption (\"" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "P" );
			Console.ResetColor( );
			Console.Error.Write( "rint\" or \"" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "text" );
			Console.ResetColor( );
			Console.Error.Write( "\") will be used for \"" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "title" );
			Console.ResetColor( );
			Console.Error.WriteLine( "\" too." );

			Console.Error.WriteLine( "          Return code 0 for \"OK\", 1 for (command line) errors, 2 for \"Cancel\"." );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Credits:  On-the-fly form based on code by Gorkem Gencay on StackOverflow:" );

			Console.ForegroundColor = ConsoleColor.DarkGray;
			Console.Error.WriteLine( "          http://stackoverflow.com/questions/97097" );

			Console.Error.WriteLine( "          /what-is-the-c-sharp-version-of-vb-nets-inputdialog#17546909" );
			Console.ResetColor( );

			Console.Error.WriteLine( "          Code to retrieve localized button captions by Martin Stoeckli:" );

			Console.ForegroundColor = ConsoleColor.DarkGray;
			Console.Error.WriteLine( "          http://martinstoeckli.ch/csharp/csharp.html#windows_text_resources" );
			Console.ResetColor( );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Written by Rob van der Woude" );

			Console.Error.WriteLine( "http://www.robvanderwoude.com" );

			#endregion Show Help Text


			return 1;
		}


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
	}


	public enum WMIPrinterStatus
	{
		Other = 1,
		Unknown = 2,
		Idle = 3,
		Printing = 4,
		Warmup = 5,
		StoppedPrinting = 6,
		Offline = 7,
		Paused = 8,
		Error = 9,
		Busy = 10,
		NotAvailable = 11,
		Waiting = 12,
		Processing = 13,
		Initialization = 14,
		PowerSave = 15,
		PendingDeletion = 16,
		IOActive = 17,
		ManualFeed = 18
	}
}
