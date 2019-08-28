using System;
using System.Globalization;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Windows.Forms;


namespace RobvanderWoude
{
	class MessageBox
	{
		static string progver = "1.30";

		static bool timeoutelapsed = false;
		static string defaultmessage = DefaultMessage( );
		static string defaulttitle = String.Format( "MessageBox {0}", progver );
		static int timeout = 0;


		static int Main( string[] args )
		{
			#region Initialize Variables

			string message = defaultmessage;
			string title = defaulttitle;
			MessageBoxButtons buttons = MessageBoxButtons.OK;
			MessageBoxIcon icon = MessageBoxIcon.Information;
			MessageBoxDefaultButton defaultbutton = MessageBoxDefaultButton.Button1;
			MessageBoxOptions option = MessageBoxOptions.DefaultDesktopOnly;
			bool buttonsset = false;
			bool defaultset = false;
			bool escapemessage = true;
			bool iconset = false;
			bool optionsset = false;
			bool useswitches = false;
			DialogResult result;
			int rc = 0;

			#endregion Initialize Variables


			#region Command Line Parsing

			foreach ( string arg in args )
			{
				if ( arg[0] == '/' )
				{
					useswitches = true;
					if ( arg.Length > 3 && arg[2] == ':' )
					{
						string key = arg[1].ToString( ).ToUpper( );
						string val = arg.Substring( 3 ).ToUpper( );
						switch ( key )
						{
							case "?":
								return DisplayHelp( );
							case "B":
								switch ( val )
								{
									case "A":
									case "ABORTRETRYIGNORE":
										buttons = MessageBoxButtons.AbortRetryIgnore;
										break;
									case "C":
									case "OKCANCEL":
										buttons = MessageBoxButtons.OKCancel;
										break;
									case "N":
									case "YESNOCANCEL":
										buttons = MessageBoxButtons.YesNoCancel;
										break;
									case "O":
									case "OK":
										buttons = MessageBoxButtons.OK;
										break;
									case "R":
									case "RETRYCANCEL":
										buttons = MessageBoxButtons.RetryCancel;
										break;
									case "Y":
									case "YESNO":
										buttons = MessageBoxButtons.YesNo;
										break;
									default:
										rc = 1;
										break;
								}
								buttonsset = true;
								break;
							case "D":
								if ( !buttonsset )
								{
									rc = 1;
								}
								switch ( val )
								{
									case "1":
									case "BUTTON1":
									case "ABORT":
									case "OK":
									case "YES":
										defaultbutton = MessageBoxDefaultButton.Button1;
										break;
									case "2":
									case "BUTTON2":
									case "NO":
										defaultbutton = MessageBoxDefaultButton.Button2;
										break;
									case "3":
									case "BUTTON3":
									case "IGNORE":
										defaultbutton = MessageBoxDefaultButton.Button3;
										break;
									case "CANCEL":
										if ( buttons == MessageBoxButtons.YesNoCancel )
										{
											defaultbutton = MessageBoxDefaultButton.Button3;
										}
										else
										{
											defaultbutton = MessageBoxDefaultButton.Button2;
										}
										break;
									case "RETRY":
										if ( buttons == MessageBoxButtons.RetryCancel )
										{
											defaultbutton = MessageBoxDefaultButton.Button1;
										}
										else
										{
											defaultbutton = MessageBoxDefaultButton.Button2;
										}
										break;
									default:
										rc = 1;
										break;
								}
								defaultset = true;
								break;
							case "I":
								switch ( val )
								{
									case "A":
									case "ASTERISK":
										icon = MessageBoxIcon.Asterisk;
										break;
									case "E":
									case "ERROR":
										icon = MessageBoxIcon.Error;
										break;
									case "H":
									case "HAND":
										icon = MessageBoxIcon.Hand;
										break;
									case "I":
									case "INFORMATION":
										icon = MessageBoxIcon.Information;
										break;
									case "N":
									case "NONE":
										icon = MessageBoxIcon.None;
										break;
									case "Q":
									case "QUESTION":
										icon = MessageBoxIcon.Question;
										break;
									case "S":
									case "STOP":
										icon = MessageBoxIcon.Stop;
										break;
									case "W":
									case "WARNING":
										icon = MessageBoxIcon.Warning;
										break;
									case "X":
									case "EXCLAMATION":
										icon = MessageBoxIcon.Exclamation;
										break;
									default:
										rc = 1;
										break;
								}
								iconset = true;
								break;
							case "O":
								switch ( val )
								{
									case "H":
									case "HIDECONSOLE":
										HideConsoleWindow( );
										break;
									case "L":
									case "RTLREADING":
										option |= MessageBoxOptions.RtlReading;
										break;
									case "N":
									case "NOESCAPE":
										escapemessage = false;
										break;
									case "R":
									case "RIGHTALIGN":
										option |= MessageBoxOptions.RightAlign;
										break;
									default:
										rc = 1;
										break;
								}
								optionsset = true;
								break;
							case "T":
								rc = CheckTimeout( val );
								break;
							default:
								rc = 1;
								break;
						}
					}
					else
					{
						rc = 1;
					}
				}
				else
				{
					if ( message == defaultmessage )
					{
						message = arg;
					}
					else if ( title == defaulttitle )
					{
						title = arg;
					}
					else if ( useswitches ) // If switches are used, only 2 "unnamed" arguments are allowed
					{
						rc = 1;
					}
					else if ( !buttonsset )
					{
						switch ( arg.ToLower( ) )
						{
							case "abortretryignore":
								buttons = MessageBoxButtons.AbortRetryIgnore;
								break;
							case "ok":
								buttons = MessageBoxButtons.OK;
								break;
							case "okcancel":
								buttons = MessageBoxButtons.OKCancel;
								break;
							case "retrycancel":
								buttons = MessageBoxButtons.RetryCancel;
								break;
							case "yesno":
								buttons = MessageBoxButtons.YesNo;
								break;
							case "yesnocancel":
								buttons = MessageBoxButtons.YesNoCancel;
								break;
							default:
								buttons = MessageBoxButtons.OK;
								rc = 1;
								break;
						}
						buttonsset = true;
					}
					else if ( !iconset )
					{
						switch ( arg.ToLower( ) )
						{
							case "asterisk":
								icon = MessageBoxIcon.Asterisk;
								break;
							case "error":
								icon = MessageBoxIcon.Error;
								break;
							case "exclamation":
								icon = MessageBoxIcon.Exclamation;
								break;
							case "hand":
								icon = MessageBoxIcon.Hand;
								break;
							case "information":
								icon = MessageBoxIcon.Information;
								break;
							case "none":
								icon = MessageBoxIcon.None;
								break;
							case "question":
								icon = MessageBoxIcon.Question;
								break;
							case "stop":
								icon = MessageBoxIcon.Stop;
								break;
							case "warning":
								icon = MessageBoxIcon.Warning;
								break;
							default:
								icon = MessageBoxIcon.Warning;
								rc = 1;
								break;
						}
						iconset = true;
					}
					else if ( !defaultset )
					{
						switch ( arg.ToLower( ) )
						{
							case "":
							case "abort":
							case "button1":
							case "ok":
							case "yes":
								defaultbutton = MessageBoxDefaultButton.Button1;
								break;
							case "button2":
							case "no":
								defaultbutton = MessageBoxDefaultButton.Button2;
								break;
							case "button3":
							case "ignore":
								defaultbutton = MessageBoxDefaultButton.Button3;
								break;
							case "cancel":
								if ( args[2].ToLower( ) == "okcancel" || args[2].ToLower( ) == "retrycancel" )
								{
									defaultbutton = MessageBoxDefaultButton.Button2;
								}
								else // yesnocancel
								{
									defaultbutton = MessageBoxDefaultButton.Button3;
								}
								break;
							case "retry":
								if ( args[2].ToLower( ) == "abortretryignore" )
								{
									defaultbutton = MessageBoxDefaultButton.Button2;
								}
								else // retrycancel
								{
									defaultbutton = MessageBoxDefaultButton.Button1;
								}
								break;
							default:
								defaultbutton = MessageBoxDefaultButton.Button1;
								rc = 1;
								break;
						}
						defaultset = true;
					}
					else if ( !optionsset )
					{
						switch ( arg.ToLower( ) )
						{
							case "":
							case "none":
								optionsset = true;
								break;
							case "hideconsole":
								HideConsoleWindow( );
								optionsset = true;
								break;
							case "noescape":
								escapemessage = false;
								optionsset = true;
								break;
							case "rightalign":
								option = MessageBoxOptions.RightAlign;
								optionsset = true;
								break;
							case "rtlreading":
								option = MessageBoxOptions.RtlReading;
								optionsset = true;
								break;
							default: // try if option is unspecified and argument is timeout
								rc = CheckTimeout( arg );
								break;
						}
					}
					else if ( timeout == 0 )
					{
						rc = CheckTimeout( arg );
					}
					else
					{
						rc = 1;
					}
				}
			}

			if ( !escapemessage && message != defaultmessage )
			{
				message = UnEscapeString( message );
				title = UnEscapeString( title );
			}

			// MessageBoxOptions.ServiceNotification allows interactive use by SYSTEM account (or any other account not currently logged in)
			option |= MessageBoxOptions.ServiceNotification;

			#endregion Command Line Parsing


			if ( rc == 1 ) // command line error
			{
				ShowConsoleWindow( );
				message = defaultmessage;
				title = defaulttitle;
				buttons = MessageBoxButtons.OK;
				icon = MessageBoxIcon.Warning;
				defaultbutton = MessageBoxDefaultButton.Button1;
				return DisplayHelp( );
			}

			if ( rc == 0 && timeout > 0 )
			{
				result = AutoClosingMessageBox.Show( message, title, timeout, buttons, icon, defaultbutton, option );
				if ( timeoutelapsed )
				{
					Console.WriteLine( "timeout" );
					return 3;
				}
			}
			else
			{
				if ( message == defaultmessage )
				{
					message = defaultmessage.Substring( 0, defaultmessage.IndexOf( "\n\nNotes:" ) ) + "\n\nWritten by Rob van der Woude\nhttp://www.robvanderwoude.com";
					result = System.Windows.Forms.MessageBox.Show( message, title, buttons, icon, defaultbutton, option );
					Console.WriteLine( result.ToString( ).ToLower( ) );
					message = defaultmessage.Substring( defaultmessage.IndexOf( "Notes:" ) );
				}
				result = System.Windows.Forms.MessageBox.Show( message, title, buttons, icon, defaultbutton, option );
			}
			Console.WriteLine( result.ToString( ).ToLower( ) );
			return rc;
		}


		static int CheckTimeout( string val )
		{
			int rc = 0;
			try
			{
				timeout = Convert.ToInt32( val ) * 1000;
				if ( timeout < 1000 )
				{
					rc = 1;
				}
			}
			catch ( FormatException )
			{
				rc = 1;
			}
			return rc;
		}


		static string DefaultMessage( )
		{
			string message = "MessageBox.exe,  Version " + progver + "\n";
			message += "Batch tool to show a message in a MessageBox and return the caption\nof the button that is clicked\n\n";
			message += "Usage:\nMessageBox \"message\" [ \"title\" ]  [ switches ]\n\n";
			message += "Or:\nMessageBox \"message\" \"title\" buttons icon default [option] timeout\n\n";
			message += "Where:\tbuttons\t\"AbortRetryIgnore\", \"OK\", \"OKCancel\",\n";
			message += "\t\t\"RetryCancel\", \"YesNo\" or \"YesNoCancel\"\n";
			message += "\ticon\t\"Asterisk\", \"Error\", \"Exclamation\", \"Hand\",\n";
			message += "\t\t\"Information\", \"None\", \"Question\", \"Stop\"\n";
			message += "\t\tor \"Warning\"\n";
			message += "\tdefault\t\"Button1\", \"Button2\" or \"Button3\" or the\n\t\tdefault button's (English) caption\n";
			message += "\toption\t\"HideConsole\", \"NoEscape\", \"RightAlign\",\n\t\t\"RtlReading\", \"None\" or \"\"\n";
			message += "\ttimeout\ttimeout interval in seconds\n\n";
			message += "Switches:\t/B:buttons\tA = AbortRetryIgnore, O = OK,\n";
			message += "        \t\t\tC = OKCancel, R = RetryCancel,\n";
			message += "        \t\t\tY = YesNo, N = YesNoCancel\n";
			message += "            \t/I:icon        \tA = Asterisk, E = Error,\n";
			message += "        \t\t\tX = Exclamation, H = Hand,\n";
			message += "        \t\t\tI = Information, N = None,\n";
			message += "        \t\t\tQ = Question, S = Stop\n";
			message += "        \t\t\tW = Warning\n";
			message += "            \t/D:default    \t1 = Button1, 2 = Button2,\n";
			message += "        \t\t\t3 = Button3 or use the default\n";
			message += "        \t\t\tbutton's (English) caption\n";
			message += "            \t/O:option     \tH = HideConsole, N = NoEscape,\n";
			message += "        \t\t\tR = RightAlign, L = RtlReading\n";
			message += "            \t/T:timeout\ttimeout interval in seconds\n\n";
			message += "Notes:\tUse switches if you want to skip arguments.\n\n";
			message += "\tAlways specify buttons BEFORE specifying default.\n\n";
			message += "\tUsing the \"HideConsole\" option will hide the console\n\twindow permanently, thereby disabling all console based\n\tuser interaction (e.g. \"ECHO\" and \"PAUSE\").\n\tIt is meant to be used in scripts that run \"hidden\"\n\tthemselves, e.g. VBScript with the WScript.exe interpreter.\n\tDo not use this option in a batch file unless hiding\n\tthe console window permanently is intended.\n\n";
			message += "\tLinefeeds (\\n or \\012 and/or \\r or \\015), tabs (\\t or \\007),\n\tsinglequotes (' or \\047) and doublequotes (\\\" or \\042)\n\tare allowed in the message string.\n";
			message += "\tEscaped Unicode characters (e.g. \"\\u5173\" for \"\u5173\")\n\tare allowed in the message string and in the title.\n";
			message += "\tUse option \"NoEscape\" to disable all character escaping\n\texcept doublequotes (useful when displaying a path).\n\n";
			message += "\tThe (English) caption of the button that was clicked\n\tis returned as text to Standard Output (in lower case),\n\tor \"timeout\" if the timeout interval expired.\n\n";
			message += "\tCode to hide console by Anthony on:\n\thttp://stackoverflow.com/a/15079092\n\n";
			message += "\tMessageBox timeout based on code by DmitryG on:\n\thttp://stackoverflow.com/a/14522952\n\n";
			message += "\tNote that when using the timeout feature, A window\n\twith the current MessageBox's TITLE will be closed,\n\tnot necessarily the current MessageBox. To prevent\n\tclosing the wrong MessageBox, use unique titles.\n\n";
			message += "\tThe return code of the program is 0 if a button was clicked,\n\t1 in case of (command line) errors, 3 if the timeout expired.\n\n";
			message += "Written by Rob van der Woude\nhttp://www.robvanderwoude.com\n";
			return message;
		}


		static int DisplayHelp()
		{
			// Display the help text in 2 message boxes AND in the console
			DisplayHelpText( );
			if ( DisplayHelpWindow( 1 ) != DialogResult.Cancel )
			{
				DisplayHelpWindow( 2 );
			}
			return 1;
		}


		static void DisplayHelpText( )
		{
			string message = DefaultMessage( );
			message = message.Replace( "\n\n\t", "\n\t" );
			message = message.Replace( "Usage:\n", "Usage:\t" );
			message = message.Replace( "Or:\n", "   or:\t" );
			Console.Error.Write( message );
		}


		static DialogResult DisplayHelpWindow( int part )
		{
			// part is 1 or 2; 1 for first half of message, 2 for second half
			string message = DefaultMessage( );
			if ( part == 1 )
			{
				message = message.Substring( 0, message.IndexOf( "\n\nNotes:" ) ) + "\n\nWritten by Rob van der Woude\nhttp://www.robvanderwoude.com";
				return System.Windows.Forms.MessageBox.Show( message, defaulttitle, MessageBoxButtons.OKCancel, MessageBoxIcon.None, MessageBoxDefaultButton.Button1, MessageBoxOptions.ServiceNotification );
			}
			else
			{
				message = message.Substring( message.IndexOf( "Notes:" ) );
				return System.Windows.Forms.MessageBox.Show( message, defaulttitle, MessageBoxButtons.OK, MessageBoxIcon.None, MessageBoxDefaultButton.Button1, MessageBoxOptions.ServiceNotification );
			}
		}


		static string UnEscapeString( string message )
		{
			// Unescaping tabs, linefeeds and quotes
			message = message.Replace( "\\n", "\n" );
			message = message.Replace( "\\r", "\r" );
			message = message.Replace( "\\t", "\t" );
			message = message.Replace( "\\007", "\t" );
			message = message.Replace( "\\012", "\n" );
			message = message.Replace( "\\015", "\r" );
			message = message.Replace( "\\042", "\"" );
			message = message.Replace( "\\047", "'" );
			// Unescaping Unicode, technique by "dtb" on StackOverflow.com: http://stackoverflow.com/a/8558748
			message = Regex.Replace( message, @"\\[Uu]([0-9A-Fa-f]{4})", m => char.ToString( (char) ushort.Parse( m.Groups[1].Value, NumberStyles.AllowHexSpecifier ) ) );
			return message;
		}


		#region Hide or Show Console
		// Source: http://stackoverflow.com/a/15079092

		public static void ShowConsoleWindow( )
		{
			var handle = GetConsoleWindow( );

			if ( handle == IntPtr.Zero )
			{
				AllocConsole( );
			}
			else
			{
				ShowWindow( handle, SW_SHOW );
			}
		}


		public static void HideConsoleWindow( )
		{
			var handle = GetConsoleWindow( );

			ShowWindow( handle, SW_HIDE );
		}


		[DllImport( "kernel32.dll", SetLastError = true )]
		static extern bool AllocConsole( );


		[DllImport( "kernel32.dll" )]
		static extern IntPtr GetConsoleWindow( );


		[DllImport( "user32.dll" )]
		static extern bool ShowWindow( IntPtr hWnd, int nCmdShow );


		const int SW_HIDE = 0;
		const int SW_SHOW = 5;

		#endregion Hide or Show Console


		#region Timed MessageBox

		// Timed MessageBox based on code by DmitryG on StackOverflow.com
		// http://stackoverflow.com/a/14522952
		public class AutoClosingMessageBox
		{
			System.Threading.Timer _timeouttimer;
			string _caption;
			DialogResult _result;


			AutoClosingMessageBox( string message, string title, int timeout, MessageBoxButtons buttons = MessageBoxButtons.OK, MessageBoxIcon icon = MessageBoxIcon.None, MessageBoxDefaultButton defaultbutton = MessageBoxDefaultButton.Button1, MessageBoxOptions option = MessageBoxOptions.DefaultDesktopOnly )
			{
				_caption = title;
				_timeouttimer = new System.Threading.Timer( OnTimerElapsed, null, timeout, System.Threading.Timeout.Infinite );

				using ( _timeouttimer )
				{
					_result = System.Windows.Forms.MessageBox.Show( message, title, buttons, icon, defaultbutton, option | MessageBoxOptions.ServiceNotification );
				}
			}


			public static DialogResult Show( string message, string title, int timeout, MessageBoxButtons buttons = MessageBoxButtons.OK, MessageBoxIcon icon = MessageBoxIcon.None, MessageBoxDefaultButton defaultbutton = MessageBoxDefaultButton.Button1, MessageBoxOptions option = MessageBoxOptions.DefaultDesktopOnly )
			{
				return new AutoClosingMessageBox( message, title, timeout, buttons, icon, defaultbutton, option | MessageBoxOptions.ServiceNotification )._result;
			}


			void OnTimerElapsed( object state )
			{
				IntPtr mbWnd = FindWindow( "#32770", _caption ); // lpClassName is #32770 for MessageBox
				if ( mbWnd != IntPtr.Zero )
				{
					SendMessage( mbWnd, WM_CLOSE, IntPtr.Zero, IntPtr.Zero );
				}
				_timeouttimer.Dispose( );
				timeoutelapsed = true;
			}


			const int WM_CLOSE = 0x0010;


			[System.Runtime.InteropServices.DllImport( "user32.dll", SetLastError = true )]
			static extern IntPtr FindWindow( string lpClassName, string lpWindowName );


			[System.Runtime.InteropServices.DllImport( "user32.dll", CharSet = System.Runtime.InteropServices.CharSet.Auto )]
			static extern IntPtr SendMessage( IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam );
		}

		#endregion Timed MessageBox
	}
}
