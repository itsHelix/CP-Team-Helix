using System;
using System.Collections.Generic;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;


namespace RobvanderWoude
{
	class DateTimeBox
	{
		static string progver = "1.12.1";


		static int Main( string[] args )
		{
			try
			{
				#region Initialize Variables

				int minwidth = 220;
				int minheight = 135;
				int maxwidth = Screen.PrimaryScreen.WorkingArea.Width;
				int maxheight = Screen.PrimaryScreen.WorkingArea.Height;
				int width = minwidth;
				int height = minheight;
				int icon = 167;
				int maxdaysfuture = 0;
				int mindaysfuture = 0;
				bool maxdaysset = false;
				bool mindaysset = false;
				bool dateonly = false;
				bool timeonly = false;
				bool initialtimeset = false;
				bool daterangeset = false;
				bool localizedcaptionset = false;
				bool canuseampm = !String.IsNullOrWhiteSpace( DateTimeFormatInfo.CurrentInfo.PMDesignator );
				bool ignoreampm = false;
				bool appendampm = false;
				string title = String.Format( "DateTimeBox,  Version {0}", progver );
				string dateformatgui = CultureInfo.CurrentCulture.DateTimeFormat.ShortDatePattern;
				string dateformatout = "yyyy-MM-dd";
				string timeformatgui = CultureInfo.CurrentCulture.DateTimeFormat.LongTimePattern;
				string timeformatout = "HH:mm:ss";
				string datetimeformatout = String.Empty;
				string cancelcaption = "&Cancel";
				string okcaption = "&OK";
				string localizationstring = String.Empty;
				string initialdatetimestring = String.Empty;
				DateTime initialdatetime = DateTime.Now;
				DateTime today = DateTime.Now.Date;
				DateTime earliest = today.Date;
				DateTime latest = today.Date;


				#endregion Initialize Variables


				#region Command Line Parsing

				if ( args.Length > 16 )
				{
					return ShowHelp( "Too many command line arguments" );
				}
				if ( args.Length > 0 )
				{
					foreach ( string arg in args )
					{
						if ( arg == "/?" )
						{
							return ShowHelp( );
						}
					}
					string localizationpattern = "(;|^)(OK|Cancel)=[^\\\"';]+(;|$)";
					string datepattern = ".*[dgkmy]+.*";
					string datetimepattern = ".*[dfghkmstyz]+.*";
					string timepattern = ".*[fhmstz]+.*";
					int count = 0;
					foreach ( string arg in args )
					{
						if ( count == 0 && arg.IndexOf( '/' ) == -1 )
						{
							// Title can only be specified as the first argument
							if ( !String.IsNullOrWhiteSpace( arg ) )
							{
								title = arg;
							}
						}
						else if ( count == 1 && arg.IndexOf( '/' ) == -1 )
						{
							// Initial date/time can only be the second argument
							initialdatetimestring = arg;
							initialtimeset = true;
						}
						else
						{
							if ( arg.IndexOf( '/' ) != 0 )
							{
								return ShowHelp( "Invalid command line argument \"{0}\"", arg );
							}
							string key = arg;
							string format = String.Empty;
							if ( arg.IndexOfAny( ":=".ToCharArray( ) ) != -1 )
							{
								key = arg.Substring( 0, arg.ToUpper( ).IndexOfAny( ":=".ToCharArray( ) ) );
								format = arg.Substring( arg.IndexOfAny( ":=".ToCharArray( ) ) + 1 );
							}
							switch ( key.ToUpper( ) )
							{
								case "/D":
									if ( dateonly )
									{
										return ShowHelp( "Duplicate command line switch /D" );
									}
									dateonly = true;
									break;
								case "/DD":
									dateformatgui = format;
									if ( !Regex.IsMatch( format, datepattern, RegexOptions.IgnoreCase ) )
									{
										return ShowHelp( "Invalid value for {0} switch: \"{1}\"", key.ToUpper( ), format );
									}
									break;
								case "/DE":
									if ( mindaysset )
									{
										return ShowHelp( "Duplicate start of allowed date range /DMIN and/or /DE" );
									}
									try
									{
										DateTime.TryParse( format, out earliest );
										mindaysfuture = ( earliest - today ).Days;
									}
									catch ( Exception )
									{
										return ShowHelp( "Invalid date format: {0}", arg );
									}
									daterangeset = true;
									mindaysset = true;
									break;
								case "/DL":
									if ( maxdaysset )
									{
										return ShowHelp( "Duplicate end of allowed date range /DMAX and/or /DL" );
									}
									try
									{
										DateTime.TryParse( format, out latest );
										maxdaysfuture = ( latest - today ).Days;
									}
									catch ( Exception )
									{
										return ShowHelp( "Invalid date format: {0}", arg );
									}
									daterangeset = true;
									maxdaysset = true;
									break;
								case "/DMAX":
									if ( maxdaysset )
									{
										return ShowHelp( "Duplicate end of allowed date range /DMAX and/or /DL" );
									}
									try
									{
										maxdaysfuture = Convert.ToInt32( format );
										latest = today.AddDays( maxdaysfuture );
									}
									catch ( Exception )
									{
										return ShowHelp( "Invalid /DMAX integer value \"{0}\"", format );
									}
									daterangeset = true;
									maxdaysset = true;
									break;
								case "/DMIN":
									if ( mindaysset )
									{
										return ShowHelp( "Duplicate start of allowed date range /DMIN and/or /DE" );
									}
									try
									{
										mindaysfuture = Convert.ToInt32( format );
										earliest = today.AddDays( mindaysfuture );
									}
									catch ( Exception )
									{
										return ShowHelp( "Invalid /DMIN integer value \"{0}\"", format );
									}
									daterangeset = true;
									mindaysset = true;
									break;
								case "/DO":
									dateformatout = format;
									if ( !Regex.IsMatch( format, datepattern, RegexOptions.IgnoreCase ) )
									{
										return ShowHelp( "Invalid value for {0} switch: \"{1}\"", key.ToUpper( ), format );
									}
									break;
								case "/DTO":
									datetimeformatout = format;
									if ( !Regex.IsMatch( format, datetimepattern, RegexOptions.IgnoreCase ) )
									{
										return ShowHelp( "Invalid value for {0} switch: \"{1}\"", key.ToUpper( ), format );
									}
									break;
								case "/FT":
									if ( initialtimeset )
									{
										return ShowHelp( "Duplicate initial date/time specification, use either \"{0}\" or {1}, not both", initialdatetimestring, arg );
									}
									string file = format;
									if ( File.Exists( file ) )
									{
										initialdatetime = File.GetLastWriteTime( file );
									}
									else
									{
										return ShowHelp( "File not found: \"{0}\"", file );
									}
									break;
								case "/H":
									if ( height != minheight )
									{
										return ShowHelp( "Duplicate command line switch /H" );
									}
									try
									{
										height = Convert.ToInt32( format );
									}
									catch ( Exception )
									{
										return ShowHelp( "Invalid height specified: {0}", arg );
									}
									break;
								case "/I":
									try
									{
										icon = Convert.ToInt32( format );
										if ( IconExtractor.Extract( "shell32.dll", icon, true ) == null )
										{
											return ShowHelp( "Invalid icon index specified for Shell32.dll: {0}", arg );
										}
									}
									catch ( Exception )
									{
										return ShowHelp( "Invalid icon index specified for Shell32.dll: {0}", arg );
									}
									break;
								case "/I24":
									ignoreampm = true;
									break;
								case "/L":
									localizedcaptionset = true;
									localizationstring = format;
									foreach ( string test in format.Split( ";".ToCharArray( ), StringSplitOptions.RemoveEmptyEntries ) )
									{
										if ( !Regex.IsMatch( format, localizationpattern, RegexOptions.IgnoreCase ) )
										{
											return ShowHelp( "Invalid value for {0} switch: \"{1}\"", key.ToUpper( ), format );
										}
									}
									break;
								case "/O24":
									appendampm = true;
									break;
								case "/T":
									if ( timeonly )
									{
										return ShowHelp( "Duplicate command line switch /T" );
									}
									timeonly = true;
									break;
								case "/TD":
									timeformatgui = format;
									if ( !Regex.IsMatch( format, timepattern, RegexOptions.IgnoreCase ) )
									{
										return ShowHelp( "Invalid value for {0} switch: \"{1}\"", key.ToUpper( ), format );
									}
									break;
								case "/TO":
									timeformatout = format;
									if ( !Regex.IsMatch( format, timepattern, RegexOptions.IgnoreCase ) )
									{
										return ShowHelp( "Invalid value for {0} switch: \"{1}\"", key.ToUpper( ), format );
									}
									break;
								case "/W":
									if ( width != minwidth )
									{
										return ShowHelp( "Duplicate command line switch /W" );
									}
									try
									{
										width = Convert.ToInt32( format );
									}
									catch ( Exception )
									{
										return ShowHelp( "Invalid width specified: {0}", arg );
									}
									break;
								default:
									return ShowHelp( "Invalid command line switch \"{0}\"", arg );
							}
						}
						count += 1;
					}
					if ( ( ( dateonly || timeonly ) && !String.IsNullOrWhiteSpace( datetimeformatout ) ) || ( dateonly && timeonly ) )
					{
						return ShowHelp( "/D, /T and /DTO cannot be combinded" );
					}
				}

				#endregion Command Line Parsing

	
				#region Command Line Validation
				
				// Validate dialog size
				if ( dateonly || timeonly )
				{
					if ( height == minheight )
					{
						height -= 40;
					}
					minheight -= 40;
				}
				if ( height > maxheight || height < minheight )
				{
					return ShowHelp( "Specified height should be in {0}..{1} range", minheight.ToString( ), maxheight.ToString( ) );
				}
				if ( width > maxwidth || width < minwidth )
				{
					return ShowHelp( "Specified width should be in {0}..{1} range", minwidth.ToString( ), maxwidth.ToString( ) );
				}

				// Validate format of initial date/time specified
				if ( !String.IsNullOrEmpty( initialdatetimestring ) )
				{
					try
					{
						if ( Regex.IsMatch( initialdatetimestring, @"^\d{4}-\d\d-\d\d \d{1,2}:\d\d$" ) )
						{
							initialdatetime = DateTime.ParseExact( initialdatetimestring, "yyyy-MM-dd HH:mm", CultureInfo.InvariantCulture );
						}
						else if ( Regex.IsMatch( initialdatetimestring, @"^\d{4}-\d\d-\d\d \d{1,2}:\d\d:\d\d$" ) )
						{
							initialdatetime = DateTime.ParseExact( initialdatetimestring, "yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture );
						}
						else if ( dateonly && Regex.IsMatch( initialdatetimestring, @"^\d{4}-\d\d-\d\d$" ) )
						{
							initialdatetime = DateTime.ParseExact( initialdatetimestring, "yyyy-MM-dd", CultureInfo.InvariantCulture );
						}
						else if ( timeonly && Regex.IsMatch( initialdatetimestring, @"^\d{1,2}:\d\d$" ) )
						{
							initialdatetime = DateTime.ParseExact( initialdatetimestring, "HH:mm", CultureInfo.InvariantCulture );
						}
						else if ( timeonly && Regex.IsMatch( initialdatetimestring, @"^\d{1,2}:\d\d:\d\d$" ) )
						{
							initialdatetime = DateTime.ParseExact( initialdatetimestring, "HH:mm:ss", CultureInfo.InvariantCulture );
						}
						else
						{
							return ShowHelp( "Invalid initial date/time format in \"{0}\"", initialdatetimestring );
						}
					}
					catch ( Exception )
					{
						return ShowHelp( "Invalid initial date/time format in \"{0}\"", initialdatetimestring );
					}
				}

				// Validate date range
				if ( daterangeset )
				{
					if ( ( latest - earliest ).Days < 0 )
					{
						return ShowHelp( "The earliest allowed date CANNOT be AFTER the latest allowed date" );
					}
				}

				#endregion Command Line Validation


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


				#region Format check

				// Check if AM/PM is required and available
				string testformats = ( dateformatgui + dateformatout + datetimeformatout + timeformatgui + timeformatout ).ToLower( );
				if ( testformats.IndexOf( 't' ) > -1 )
				{
					if ( canuseampm )
					{
						ignoreampm = false;
						appendampm = false;
					}
					else
					{
						if ( timeformatgui.IndexOf( 't' ) > -1 )
						{
							if ( ignoreampm )
							{
								timeformatgui = Regex.Replace( timeformatgui, @"\s*t+", String.Empty );
								timeformatgui = Regex.Replace( timeformatgui, "h", "H" );
							}
							else
							{
								return ShowHelp( "AM/PM time format not available on this computer, use /I24\n\tto ignore this error and use a 24-hour time picker instead,\n\tand /O24 to append AM/PM to the output result" );
							}
						}
						if ( ( timeformatout + datetimeformatout ).IndexOf( 't' ) > -1 )
						{
							if ( appendampm )
							{
								datetimeformatout = Regex.Replace( datetimeformatout, @"\s*t+", String.Empty );
								timeformatout = Regex.Replace( timeformatout, @"\s*t+", String.Empty );
							}
							else
							{
								return ShowHelp( "AM/PM time format not available on this computer,\n\tuse /O24 to append AM/PM to the output result" );
							}
						}
						else
						{
							appendampm = false;
						}
					}
				}

				// Check validity of specified formats
				if ( String.IsNullOrWhiteSpace( datetimeformatout ) )
				{
					DateTime d = DateTime.Now;
					DateTime t = DateTime.Now;
					string date = String.Empty;
					string time = String.Empty;
					if ( !timeonly )
					{
						try
						{
							date = d.ToString( dateformatgui, CultureInfo.InvariantCulture );
							d = DateTime.ParseExact( date, dateformatgui, CultureInfo.InvariantCulture );
						}
						catch ( FormatException )
						{
							return ShowHelp( "Invalid date display format \"{0}\"", dateformatgui );
						}
						try
						{
							date = d.ToString( dateformatout, CultureInfo.InvariantCulture );
						}
						catch ( FormatException )
						{
							return ShowHelp( "Invalid date output format \"{0}\"", dateformatout );
						}
					}
					if ( !dateonly )
					{
						try
						{
							time = t.ToString( timeformatgui, CultureInfo.InvariantCulture );
							t = DateTime.ParseExact( time, timeformatgui, CultureInfo.InvariantCulture );
						}
						catch ( FormatException )
						{
							t = DateTime.ParseExact( time, timeformatgui, CultureInfo.CurrentCulture );
						}
						try
						{
							time = t.ToString( timeformatout, CultureInfo.InvariantCulture );
						}
						catch ( FormatException )
						{
							return ShowHelp( "Invalid time output format \"{0}\"", timeformatout );
						}
					}
				}
				else
				{
					DateTime dt;
					string datetime;
					try
					{
						dt = DateTime.ParseExact( DateTime.Now.ToString( dateformatgui + " " + timeformatgui, CultureInfo.InvariantCulture ), dateformatgui + " " + timeformatgui, CultureInfo.InvariantCulture );
					}
					catch ( FormatException )
					{
						return ShowHelp( "Invalid date/time display format \"{0}\"", dateformatgui + " " + timeformatgui );
					}
					try
					{
						datetime = dt.ToString( datetimeformatout, CultureInfo.InvariantCulture );
					}
					catch ( FormatException )
					{
						return ShowHelp( "Invalid date/time output format \"{0}\"", datetimeformatout );
					}
				}

				#endregion Format check


				#region Form Controls

				Size size = new Size( width, height );
				Form dtForm = new Form( );
				dtForm.ClientSize = size;
				dtForm.FormBorderStyle = FormBorderStyle.FixedDialog;
				dtForm.MaximizeBox = false;
				dtForm.MinimizeBox = false;
				dtForm.StartPosition = FormStartPosition.CenterScreen;
				dtForm.Text = title;
				dtForm.Icon = IconExtractor.Extract( "shell32.dll", icon, true );

				Point firstrow = new Point( 15, 15 );
				Point secondrow = new Point( 15, 55 );

				DateTimePicker datePicker = null;
				if ( !timeonly )
				{
					datePicker = new DateTimePicker( );
					if ( timeonly || String.IsNullOrWhiteSpace( dateformatgui ) )
					{
						datePicker.Format = DateTimePickerFormat.Long;
					}
					else
					{
						datePicker.CustomFormat = dateformatgui;
						datePicker.Format = DateTimePickerFormat.Custom;
					}
					datePicker.Location = firstrow;
					if ( daterangeset )
					{
						datePicker.MaxDate = latest;
						datePicker.MinDate = earliest;
					}
					datePicker.Size = new Size( size.Width - 30, 25 );
					if ( daterangeset )
					{
						if ( ( earliest - initialdatetime ).Days > 0 )
						{
							datePicker.Value = earliest;
						}
						else if ( ( initialdatetime - latest ).Days > 0 )
						{
							datePicker.Value = latest;
						}
						else
						{
							datePicker.Value = initialdatetime;
						}
					}
					else
					{
						datePicker.Value = initialdatetime;
					}
					dtForm.Controls.Add( datePicker );
				}

				DateTimePicker timePicker = null;
				if ( !dateonly )
				{
					timePicker = new DateTimePicker( );
					if ( dateonly || String.IsNullOrWhiteSpace( timeformatgui ) )
					{
						timePicker.Format = DateTimePickerFormat.Time;
					}
					else
					{
						timePicker.CustomFormat = timeformatgui;
						timePicker.Format = DateTimePickerFormat.Custom;
					}
					if ( timeonly )
					{
						timePicker.Location = firstrow;
					}
					else
					{
						timePicker.Location = secondrow;
					}
					timePicker.ShowUpDown = true;
					timePicker.Size = new Size( size.Width - 30, 25 );
					timePicker.Value = initialdatetime;
					dtForm.Controls.Add( timePicker );
				}

				Button okButton = new Button( );
				okButton.DialogResult = DialogResult.OK;
				okButton.Name = "okButton";
				okButton.Size = new Size( 80, 25 );
				okButton.Text = okcaption;
				okButton.Location = new Point( size.Width / 2 - 10 - 80, size.Height - 43 );
				dtForm.Controls.Add( okButton );

				Button cancelButton = new Button( );
				cancelButton.DialogResult = DialogResult.Cancel;
				cancelButton.Name = "cancelButton";
				cancelButton.Size = new Size( 80, 25 );
				cancelButton.Text = cancelcaption;
				cancelButton.Location = new Point( size.Width / 2 + 10, size.Height - 43 );
				dtForm.Controls.Add( cancelButton );

				dtForm.AcceptButton = okButton;  // OK on Enter
				dtForm.CancelButton = cancelButton; // Cancel on Esc
				dtForm.Activate( );

				#endregion Form Controls


				DialogResult result = dtForm.ShowDialog( );
				if ( result == DialogResult.OK )
				{
					string datetime = String.Empty;
					string ampm = String.Empty;
					if ( String.IsNullOrWhiteSpace( datetimeformatout ) )
					{
						string date = String.Empty;
						string time = String.Empty;
						if ( !timeonly )
						{
							date = DateTime.ParseExact( datePicker.Text, dateformatgui, CultureInfo.InvariantCulture ).ToString( dateformatout, CultureInfo.InvariantCulture );
						}
						if ( !dateonly )
						{
							try
							{
								time = DateTime.ParseExact( timePicker.Text, timeformatgui, CultureInfo.InvariantCulture ).ToString( timeformatout, CultureInfo.InvariantCulture );
							}
							catch ( FormatException )
							{
								time = DateTime.ParseExact( timePicker.Text, timeformatgui, CultureInfo.CurrentCulture ).ToString( timeformatout, CultureInfo.InvariantCulture );
							}
						}
						if ( !canuseampm && appendampm )
						{
							ampm = DateTime.ParseExact( timePicker.Text, timeformatgui, CultureInfo.CurrentCulture ).ToString( "tt", new CultureInfo( "en-US" ) );
						}
						Console.WriteLine( String.Format( "{0}, {1} {2}", date, time, ampm ).Trim( ", ".ToCharArray( ) ) );
					}
					else
					{
						datetime = DateTime.ParseExact( datePicker.Text + " " + timePicker.Text, dateformatgui + " " + timeformatgui, CultureInfo.InvariantCulture ).ToString( datetimeformatout, CultureInfo.InvariantCulture );
						if ( !canuseampm && appendampm )
						{
							ampm = DateTime.ParseExact( timePicker.Text, timeformatgui, CultureInfo.CurrentCulture ).ToString( "tt", new CultureInfo( "en-US" ) );
						}
						Console.WriteLine( String.Format( "{0} {1}", datetime, ampm ).Trim( ) );
					}
					return 0;
				}
				else
				{
					return 2; // Canceled
				}
			}
			catch ( Exception e )
			{
				return ShowHelp( "{0}\n\t{1}", e.Message, e.StackTrace );
			}
		}


		#region Error handling

		public static int ShowHelp( params string[] errmsg )
		{
			#region Help Text

			/*
			DateTimeBox,  Version 1.12
			Batch tool to present a Date/Time Picker dialog and return the selected
			date and/or time in the specified format

			Usage:    DATETIMEBOX  [ "title" ]  [ "datetime" ]  [ options ]

			Where:    "title"    is the optional caption in the title bar
			                     (default: program name and version)
			          "datetime" is the optional initial date/time for the dialog
			                     in "yyyy-MM-dd HH:mm" format      (default: now)
			          options    /D   display and return Date only (default: date and time)
			                     /T   display and return Time only (default: date and time)
			                     /I24 Ignore AM/PM in Input on systems with 24-hour format
			                     /O24 append AM/PM to Output on systems with 24-hour format
			                     /FT:"file"          use File Timestamp of specified file
			                                         for the dialog's initial date/time
			                     /DD:dateformat      Date Display format (GUI)
			                     /DO:dateformat      Date Output string format
			                     /TD:timeformat      Time Display format (GUI)
			                     /TO:timeformat      Time Output string format
			                     /DTO:datetimeformat Date and Time Output string format
			                     /DE:yyyy-MM-dd      Earliest date allowed
			                     /DL:yyyy-MM-dd      Latest date allowed
			                     /DMAX:numberofdays  MAXimum Date allowed, relative to
			                                         today, in days (negative number for
			                                         a date in the past)
			                     /DMIN:numberofdays  MINimum Date allowed, relative to
			                                         today, in days (negative number for
			                                         a date in the past)
			                     /H:height           window Height (default: 135,
			                                         minimum: 135, maximum: screen height)
			                     /I:index            use Icon at index from shell32.dll
			                     /L[:captions]       Localize or customize button captions
			                                         (e.g. /L:"OK=Why Not?;Cancel=Never!")
			                     /W:width            window Width (default: 220,
			                                         minimum: 220, maximum: screen width)

			Example:  Display date/time in default format, output in yyyyMMddHHmmssfff
			          format (year, month, day, hours, minutes, seconds, milliseconds),
			          selected date between today and 90 days in the future:
			          DATETIMEBOX "When?" /DTO:yyyyMMddHHmmssfff /DMIN:0 /DMAX:90

			Notes:    Available custom date and time formats can be found on MSDN at:
			          http://msdn.microsoft.com/en-us/library/8kb3ddd4.aspx
			          Note that by default AM/PM time formats ("tt" or "t") cannot be
			          used on computers with a 24-hour time format. To prevent error
			          messages, use /I24 to ignore "tt" or "t" (AM/PM) in specified input
			          and/or output format, and /O24 to append AM/PM to the string on
			          systems with 24-hour time format.
			          If specified, the initial date/time must be in "yyyy-MM-dd HH:mm"
			          or "yyyy-MM-dd HH:mm:ss" format; but with /D "yyyy-MM-dd" format is
			          accepted, and with /T "HH:mm" and "HH:mm:ss" formats are accepted.
			          If specified without captions, switch /L forces localized button
			          captions (e.g. "Cancel" button caption is "Annuleren" on Dutch
			          systems); if only a single custom caption is specified, the other
			          one is localized (e.g. with /L:"OK=Gaan" on Dutch systems, "OK"
			          button caption is "Gaan", "Cancel" button caption is "Annuleren").
			          The selected date and/or time are written to Standard Out if "OK"
			          is clicked, otherwise an empty string is returned.
			          Switches /D, /T and /DTO are mutually exclusive, as are /DMAX and
			          /DL, and /DMIN and /DE.
			          Return code 0 for "OK", 1 for (command line) errors, 2 for "Cancel".

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


			#region Show Help

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "DateTimeBox,  Version {0}", progver );

			Console.Error.WriteLine( "Batch tool to present a Date/Time Picker dialog and return the selected" );

			Console.Error.WriteLine( "date and/or time in the specified format" );

			Console.Error.WriteLine( );

			Console.Error.Write( "Usage:    " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "DATETIMEBOX  [ \"title\" ]  [ \"datetime\" ]  [ options ]" );
			Console.ResetColor( );

			Console.Error.WriteLine( );

			Console.Error.Write( "Where:    " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"title\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( "    is the optional caption in the title bar" );

			Console.Error.WriteLine( "                     (default: DateTimeBox,  Version {0})", progver );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          \"datetime\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( " is the optional initial date/time for the dialog" );

			Console.Error.WriteLine( "                     in \"yyyy-MM-dd HH:mm\" format      (default: now)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          options    /D" );
			Console.ResetColor( );
			Console.Error.Write( "   display and return " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "D" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ate only (default: date and time)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /T" );
			Console.ResetColor( );
			Console.Error.Write( "   display and return " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "T" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ime only (default: date and time)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /I24 I" );
			Console.ResetColor( );
			Console.Error.Write( "gnore AM/PM in " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "I" );
			Console.ResetColor( );
			Console.Error.Write( "nput on systems with " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "24" );
			Console.ResetColor( );
			Console.Error.WriteLine( "-hour format" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /O24" );
			Console.ResetColor( );
			Console.Error.Write( " append AM/PM to " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "O" );
			Console.ResetColor( );
			Console.Error.Write( "utput on systems with " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "24" );
			Console.ResetColor( );
			Console.Error.WriteLine( "-hour format" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /FT:\"file\"" );
			Console.ResetColor( );
			Console.Error.Write( "          use " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "F" );
			Console.ResetColor( );
			Console.Error.Write( "ile " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "T" );
			Console.ResetColor( );
			Console.Error.Write( "imestamp of specified " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "file" );
			Console.ResetColor( );

			Console.Error.WriteLine( "                                         for the dialog's initial date/time" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /DD:dateformat      D" );
			Console.ResetColor( );
			Console.Error.Write( "ate " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "D" );
			Console.ResetColor( );
			Console.Error.WriteLine( "isplay format (GUI)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /DO:dateformat      D" );
			Console.ResetColor( );
			Console.Error.Write( "ate " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "O" );
			Console.ResetColor( );
			Console.Error.WriteLine( "utput string format" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /TD:timeformat      T" );
			Console.ResetColor( );
			Console.Error.Write( "ime " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "D" );
			Console.ResetColor( );
			Console.Error.WriteLine( "isplay format (GUI)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /TO:timeformat      T" );
			Console.ResetColor( );
			Console.Error.Write( "ime " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "O" );
			Console.ResetColor( );
			Console.Error.WriteLine( "utput string format" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /DTO:datetimeformat D" );
			Console.ResetColor( );
			Console.Error.Write( "ate and " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "T" );
			Console.ResetColor( );
			Console.Error.Write( "ime " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "O" );
			Console.ResetColor( );
			Console.Error.WriteLine( "utput string format" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /DE:yyyy-MM-dd      E" );
			Console.ResetColor( );
			Console.Error.Write( "arliest " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "D" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ate allowed" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /DL:yyyy-MM-dd      L" );
			Console.ResetColor( );
			Console.Error.Write( "atest " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "D" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ate allowed" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /DMAX:numberofdays  MAX" );
			Console.ResetColor( );
			Console.Error.Write( "imum " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "D" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ate allowed, relative to" );

			Console.Error.Write( "                                         today, in " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "days" );
			Console.ResetColor( );
			Console.Error.WriteLine( " (negative number for" );

			Console.Error.WriteLine( "                                         a date in the past)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /DMIN:numberofdays  MIN" );
			Console.ResetColor( );
			Console.Error.Write( "imum " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "D" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ate allowed, relative to" );

			Console.Error.Write( "                                         today, in " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "days" );
			Console.ResetColor( );
			Console.Error.WriteLine( " (negative number for" );

			Console.Error.WriteLine( "                                         a date in the past)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /H:height" );
			Console.ResetColor( );
			Console.Error.Write( "           window " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "H" );
			Console.ResetColor( );
			Console.Error.WriteLine( "eight (default: 135," );

			Console.Error.WriteLine( "                                         minimum: 135, maximum: screen height)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /I:index" );
			Console.ResetColor( );
			Console.Error.Write( "            use " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "I" );
			Console.ResetColor( );
			Console.Error.Write( "con at " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "index" );
			Console.ResetColor( );
			Console.Error.WriteLine( " from shell32.dll" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /L[:captions]       L" );
			Console.ResetColor( );
			Console.Error.Write( "ocalize or customize button " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "captions" );
			Console.ResetColor( );

			Console.Error.Write( "                                         (e.g. " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/L:\"OK=Why Not?;Cancel=Never!\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( ")" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /W:width" );
			Console.ResetColor( );
			Console.Error.Write( "            window " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "W" );
			Console.ResetColor( );
			Console.Error.WriteLine( "idth (default: 220," );

			Console.Error.WriteLine( "                                         minimum: 220, maximum: screen width)" );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Example:  Display date/time in default format, output in yyyyMMddHHmmssfff" );

			Console.Error.WriteLine( "          format (year, month, day, hours, minutes, seconds, milliseconds)," );

			Console.Error.WriteLine( "          selected date between today and 90 days in the future:" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "          DATETIMEBOX \"When?\" /DTO:yyyyMMddHHmmssfff /DMIN:0 /DMAX:90" );
			Console.ResetColor( );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Notes:    Available custom date and time formats can be found on MSDN at:" );

			Console.ForegroundColor = ConsoleColor.DarkGray;
			Console.Error.WriteLine( "          http://msdn.microsoft.com/en-us/library/8kb3ddd4.aspx" );
			Console.ResetColor( );

			Console.Error.WriteLine( "          Note that by default AM/PM time formats (\"tt\" or \"t\") cannot be" );

			Console.Error.WriteLine( "          used on computers with a 24-hour time format. To prevent error" );

			Console.Error.Write( "          messages, use " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/I24" );
			Console.ResetColor( );
			Console.Error.WriteLine( " to ignore \"tt\" or \"t\" (AM/PM) in specified input" );

			Console.Error.Write( "          and/or output format, and " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/O24" );
			Console.ResetColor( );
			Console.Error.WriteLine( " to append AM/PM to the string on" );

			Console.Error.WriteLine( "          systems with 24-hour time format." );

			Console.Error.WriteLine( "          If specified, the initial date/time must be in \"yyyy-MM-dd HH:mm\"" );

			Console.Error.Write( "          or \"yyyy-MM-dd HH:mm:ss\" format; but with " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/D" );
			Console.ResetColor( );
			Console.Error.WriteLine( " \"yyyy-MM-dd\" format is" );

			Console.Error.Write( "          accepted, and with " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/T" );
			Console.ResetColor( );
			Console.Error.WriteLine( " \"HH:mm\" and \"HH:mm:ss\" formats are accepted." );

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

			Console.Error.WriteLine( "          The selected date and/or time are written to Standard Out if \"OK\"" );

			Console.Error.WriteLine( "          is clicked, otherwise an empty string is returned." );

			Console.Error.Write( "          Switches " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/D" );
			Console.ResetColor( );
			Console.Error.Write( ", " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/T" );
			Console.ResetColor( );
			Console.Error.Write( " and " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/DTO" );
			Console.ResetColor( );
			Console.Error.WriteLine( " are mutually exclusive." );

			Console.Error.WriteLine( "          Return code 0 for \"OK\", 1 for (command line) errors, 2 for \"Cancel\"." );

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

			#endregion Show Help


			return 1;
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
