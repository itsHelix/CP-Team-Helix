using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Windows.Forms;


namespace RobvanderWoude
{
	class SaveFileBox
	{
		static string progver = "1.02";

		[STAThread]
		static int Main( string[] args )
		{
			using ( SaveFileDialog dialog = new SaveFileDialog( ) )
			{
				string filter = "All files (*.*)|*.*";
				string ext = ".*";
				string folder = Directory.GetCurrentDirectory( );
				string title = "SaveFileBox,  Version " + progver;
				bool forceext = false;
				bool overwrite = false;
				bool verbose = false;
				bool forcespec = false;
				bool promptspec = false;

				#region Command Line Parsing

				foreach ( string arg in args )
				{
					if ( arg == "/?" )
					{
						return ShowHelp( );
					}
				}
				if ( args.Length > 5 )
				{
					return ShowHelp( "Too many command line arguments" );
				}
				if ( args.Length > 0 )
				{
					filter = args[0];
					ext = Regex.Match( filter, @"(\.[^.]+)$", RegexOptions.IgnoreCase ).Groups[0].ToString( );
					if ( String.IsNullOrWhiteSpace( ext ) )
					{
						return ShowHelp( "Invalid filetype specification" );
					}
					// If only "*.ext" is specified, use "ext files (*.ext)|*.ext" instead
					if ( Regex.IsMatch( filter, @"^\*\.(\*|\w+)$" ) )
					{
						if ( ext == ".*" )
						{
							filter = String.Format( "All files (*.{0})|*.{0}", ext );
						}
						else
						{
							filter = String.Format( "{0} files (*.{0})|*.{0}", ext );
						}
					}
					// Use "All files" filter if not specified
					if ( String.IsNullOrWhiteSpace( filter ) )
					{
						filter = "All files (*.*)|*.*";
					}
					// Optional second command line argument is start folder
					if ( args.Length > 1 )
					{
						try
						{
							folder = Path.GetFullPath( args[1] );
						}
						catch ( ArgumentException )
						{
							// Assuming the error was caused by a trailing bacslash in doublequotes
							folder = args[1].Substring( 0, args[1].IndexOf( '"' ) );
							folder = Path.GetFullPath( folder + "." );
						}
						if ( !Directory.Exists( folder ) )
						{
							return ShowHelp( "Invalid folder \"{0}\"", folder );
						}
						// Optional third command line argument is dialog title
						if ( args.Length > 2 )
						{
							title = args[2];
							if ( args.Length > 3 )
							{
								foreach ( string arg in args.Skip<string>( 2 ) )
								{
									switch ( arg.ToUpper( ) )
									{
										case "/F":
											if ( forcespec )
											{
												return ShowHelp( "Duplicate command line switch /F" );
											}
											forceext = true;
											forcespec = true;
											break;
										case "/Q":
											if ( promptspec )
											{
												return ShowHelp( "Duplicate command line switches or invalid combination" );
											}
											overwrite = true;
											promptspec = true;
											break;
										case "/V":
											if ( promptspec )
											{
												return ShowHelp( "Duplicate command line switches or invalid combination" );
											}
											verbose = true;
											promptspec = true;
											break;
										default:
											return ShowHelp( "Invalid command line argument \"{0}\"", arg );
									}
								}
							}
						}
					}
				}

				#endregion Command Line Parsing


				dialog.Filter = filter;
				dialog.FilterIndex = 1;
				dialog.InitialDirectory = folder;
				dialog.AddExtension = forceext;
				dialog.DefaultExt = ext;
				dialog.CheckFileExists = false;
				dialog.CheckPathExists = !overwrite;
				dialog.CreatePrompt = false;
				dialog.OverwritePrompt = false;
				dialog.SupportMultiDottedExtensions = true;
				dialog.Title = title;
				dialog.RestoreDirectory = true;
				if ( dialog.ShowDialog( ) == DialogResult.OK )
				{
					string filename = dialog.FileName;
					if ( forceext )
					{
						string newext = Path.GetExtension( filename );
						if ( String.Compare( newext, ext, true ) != 0 )
						{
							filename += ext;
						}
					}
					if ( File.Exists( filename ) )
					{
						// File exists
						if ( !overwrite )
						{
							string prompt = String.Format( "The file \"{0}\" already exists.\n\nDo you want to replace it?", Path.GetFileName( filename ) );
							string caption = "Overwrite File?";
							MessageBoxButtons buttons = MessageBoxButtons.YesNo;
							MessageBoxIcon icon = MessageBoxIcon.Warning;
							DialogResult result = MessageBox.Show( prompt, caption, buttons, icon, MessageBoxDefaultButton.Button2 );
							if ( result != DialogResult.Yes )
							{
								// Canceled
								return 2;
							}
						}
						// Overwrite approved
						Console.WriteLine( filename );
						return 3;
					}
					else
					{
						// File does not exist
						if ( verbose )
						{
							string prompt = String.Format( "The file \"{0}\" does not exist.\n\nDo you want to create it?", Path.GetFileName( filename ) );
							string caption = "Create File?";
							MessageBoxButtons buttons = MessageBoxButtons.YesNo;
							MessageBoxIcon icon = MessageBoxIcon.Question;
							DialogResult result = MessageBox.Show( prompt, caption, buttons, icon, MessageBoxDefaultButton.Button1 );
							if ( result != DialogResult.Yes )
							{
								// Canceled
								return 2;
							}
						}
						// OK
						Console.WriteLine( filename );
						return 0;
					}
				}
				else
				{
					// Canceled
					return 2;
				}
			}
		}

		static int ShowHelp( params string[] errmsg )
		{
			/*
			SaveFileBox.exe,  Version 1.02
			Batch tool to present a Save File dialog and return the selected file path

			Usage:  SAVEFILEBOX  "filetypes"  "startfolder"  "title"  options

			Where:  filetypes    file type(s) in format "description (*.ext)|*.ext"
			                     or just "*.ext" (default: "All files (*.*)|*.*")
			        startfolder  the initial folder the dialog will show on opening
			                     (default: current directory)
			        title        the caption in the dialog's title bar
			                     (default: program name and version)
			        options      /F    Force specified extension
			                     /Q    Quiet mode: do not check if the file exists
			                     /V    Verbose mode: prompt for confirmation
			                     (default: prompt only if file exists)

			Notes:  This batch tool does not actually save the file, it is only intended
			        to interactively specify a file path, which can be used by the calling
			        batch file.
			        All command line arguments are optional, but each argument requires
			        the ones preceeding it, e.g. "startfolder" requires "filetypes" but
			        not necessarily "title" and options.
			        Options /Q and /V are mutually exclusive.
			        If the filetypes filter is in "*.ext" format, "ext files (*.ext)|*.ext"
			        will be used instead.
			        The full path of the selected file is written to Standard Output
			        if OK was clicked, or an empty string if Cancel was clicked.
			        The return code will be 0 on success, 1 in case of (command line)
			        errors, 2 on Cancel, 3 if not in Quiet mode and file exists.

			Written by Rob van der Woude
			http://www.robvanderwoude.com
			*/

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

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "SaveFileBox.exe,  Version {0}", progver );

			Console.Error.WriteLine( "Batch tool to present a Save File dialog and return the selected file path" );

			Console.Error.WriteLine( );

			Console.Error.Write( "Usage:  " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "SAVEFILEBOX  \"filetypes\"  \"startfolder\"  \"title\"  options" );
			Console.ResetColor( );

			Console.Error.WriteLine( );

			Console.Error.Write( "Where:  " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "filetypes" );
			Console.ResetColor( );
			Console.Error.Write( "    file type(s) in format " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "\"description (*.ext)|*.ext\"" );
			Console.ResetColor( );

			Console.Error.Write( "                     or just " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"*.ext\"" );
			Console.ResetColor( );
			Console.Error.Write( " (default: " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"All files (*.*)|*.*\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( ")" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "        startfolder" );
			Console.ResetColor( );
			Console.Error.WriteLine( "  the initial folder the dialog will show on opening" );

			Console.Error.WriteLine( "                     (default: current directory)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "        title" );
			Console.ResetColor( );
			Console.Error.WriteLine( "        the caption in the dialog's title bar" );

			Console.Error.WriteLine( "                     (default: \"SaveFileBox,  Version {0})\"", progver );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "        options      /F    F" );
			Console.ResetColor( );
			Console.Error.WriteLine( "orce specified extension" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /Q    Q" );
			Console.ResetColor( );
			Console.Error.WriteLine( "uiet mode: do not check if the file exists" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "                     /V    V" );
			Console.ResetColor( );
			Console.Error.WriteLine( "erbose mode: prompt for confirmation" );

			Console.Error.WriteLine( "                     (default: prompt only if file exists)" );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Notes:  This batch tool does not actually save the file, it is only intended" );

			Console.Error.WriteLine( "        to interactively specify a file path, which can be used by the calling" );

			Console.Error.WriteLine( "        batch file." );

			Console.Error.WriteLine( "        All command line arguments are optional, but each argument requires" );

			Console.Error.Write( "        the ones preceeding it, e.g. " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"startfolder\"" );
			Console.ResetColor( );
			Console.Error.Write( " requires " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"filetypes\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( " but" );

			Console.Error.Write( "        not necessarily " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"title\"" );
			Console.ResetColor( );
			Console.Error.Write( " and " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "options" );
			Console.ResetColor( );
			Console.Error.WriteLine( "." );

			Console.Error.Write( "        Options " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/Q" );
			Console.ResetColor( );
			Console.Error.Write( " and " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/V" );
			Console.ResetColor( );
			Console.Error.WriteLine( " are mutually exclusive." );

			Console.Error.Write( "        If the filetypes filter is in " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"*.ext\"" );
			Console.ResetColor( );
			Console.Error.Write( " format, " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "\"ext files (*.ext)|*.ext\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( "        will be used instead." );

			Console.Error.WriteLine( "        The full path of the selected file is written to Standard Output" );

			Console.Error.WriteLine( "        if OK was clicked, or an empty string if Cancel was clicked." );

			Console.Error.WriteLine( "        The return code will be 0 on success, 1 in case of (command line)" );

			Console.Error.WriteLine( "        errors, 2 on Cancel, 3 if not in Quiet mode and file exists." );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Written by Rob van der Woude" );

			Console.Error.WriteLine( "http://www.robvanderwoude.com" );

			return 1;
		}
	}
}
