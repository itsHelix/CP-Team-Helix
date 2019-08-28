using System;
using System.IO;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Windows.Forms;


namespace RobvanderWoude
{
	class OpenFile
	{
		static string progver = "1.04";

		[STAThread]
		static int Main( string[] args )
		{
			foreach ( string arg in args )
			{
				if ( arg == "/?" )
				{
					return ShowHelp( );
				}
			}

			using ( OpenFileDialog dialog = new OpenFileDialog( ) )
			{
				string filter = "All files (*.*)|*.*";
				string folder = Directory.GetCurrentDirectory( );
				string title = String.Format( "OpenFileBox,  Version {0}", progver );

				if ( args.Length > 3 )
				{
					return ShowHelp( "Too many command line arguments" );
				}
				if ( args.Length > 0 )
				{
					filter = args[0];
					// If only "*.ext" is specified, use "ext files (*.ext)|*.ext" instead
					if ( Regex.IsMatch( filter, @"^\*\.(\*|\w+)$" ) )
					{
						string ext = filter.Substring( 2 ).ToLower( );
						if ( ext == ".*" )
						{
							filter = String.Format( "All files (*.{0})|*.{0}", ext );
						}
						else
						{
							filter = String.Format( "{0} files (*.{0})|*.{0}", ext );
						}
					}
					// Append "All files" filter if not specified
					if ( !Regex.IsMatch( filter, @"All files\s+\(\*\.\*\)\|\*\.\*", RegexOptions.IgnoreCase ) )
					{
						if ( String.IsNullOrWhiteSpace( filter ) )
						{
							filter = "All files (*.*)|*.*";
						}
						else
						{
							filter = filter + "|All files (*.*)|*.*";
						}
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
							// Assuming the error is caused by a trailing backslash in doublequotes
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
						}
					}
				}
				dialog.Filter = filter;
				dialog.FilterIndex = 1;
				dialog.InitialDirectory = folder;
				dialog.Title = title;
				dialog.RestoreDirectory = true;
				if ( dialog.ShowDialog( ) == DialogResult.OK )
				{
					Console.WriteLine( dialog.FileName );
					return 0;
				}
				else
				{
					// Cancel was clicked
					return 2;
				}
			}
		}

		static int ShowHelp( params string[] errmsg )
		{
			/*
			OpenFileBox.exe,  Version 1.04
			Batch tool to present an Open File Dialog and return the selected file path

			Usage:  OPENFILEBOX  [ "filetypes"  [ "startfolder"  [ "title" ] ] ]

			Where:  filetypes    file type(s) in format "description (*.ext)|*.ext"
			                     or just "*.ext" (default: "All files (*.*)|*.*")
			        startfolder  the initial folder the dialog will show on opening
			                     (default: current directory)
			        title        the caption in the dialog's title bar
			                     (default: program name and version)

			Notes:  This batch tool does not actually open the selected file, it is only
			        intended to interactively select a file, which can be used by the
			        calling batch file.
			        Multiple file types can be used for the filetypes filter; use "|" as a
			        separator, e.g. "PDF files (*.pdf)|*.txt|Word documents (*.doc)|*.doc".
			        If the filetypes filter is in "*.ext" format, "ext files (*.ext)|*.ext"
			        will be used instead.
			        Unless the filetypes filter specified is "All files (*.*)|*.*" or
			        "*.*", the filetypes filter "|All files (*.*)|*.*" will be appended.
			        The full path of the selected file is written to Standard Output
			        if OK was clicked, or an empty string if Cancel was clicked.
			        The return code will be 0 on success, 1 in case of (command line)
			        errors, or 2 if Cancel was clicked.

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

			Console.Error.WriteLine( "OpenFileBox.exe,  Version {0}", progver );

			Console.Error.WriteLine( "Batch tool to present an Open File Dialog and return the selected file path" );

			Console.Error.WriteLine( );

			Console.Error.Write( "Usage:  " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "OPENFILEBOX  [ \"filetypes\"  [ \"startfolder\"  [ \"title\" ] ] ]" );
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

			Console.Error.WriteLine( "                     (default: \"OpenFileBox,  Version {0})\"", progver );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Notes:  This batch tool does not actually open the selected file, it is only" );

			Console.Error.WriteLine( "        intended to interactively select a file, which can be used by the" );

			Console.Error.WriteLine( "        calling batch file." );

			Console.Error.WriteLine( "        Multiple file types can be used for the filetypes filter; use \"|\" as a" );

			Console.Error.Write( "        separator, e.g. " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "\"PDF files (*.pdf)|*.txt|Word documents (*.doc)|*.doc\"." );
			Console.ResetColor( );

			Console.Error.Write( "        If the filetypes filter is in " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"*.ext\"" );
			Console.ResetColor( );
			Console.Error.Write( " format, " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "\"ext files (*.ext)|*.ext\"" );
			Console.ResetColor( );

			Console.Error.WriteLine( "        will be used instead." );

			Console.Error.Write( "        Unless the filetypes filter specified is " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"All files (*.*)|*.*\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( " or" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "        \"*.*\"" );
			Console.ResetColor( );
			Console.Error.Write( ", the filetypes filter " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "\"|All files (*.*)|*.*\"" );
			Console.ResetColor( );
			Console.Error.WriteLine( " will be appended." );


			Console.Error.WriteLine( "        The full path of the selected file is written to Standard Output" );

			Console.Error.WriteLine( "        if OK was clicked, or an empty string if Cancel was clicked." );

			Console.Error.WriteLine( "        The return code will be 0 on success, 1 in case of (command line)" );

			Console.Error.WriteLine( "        errors, or 2 if Cancel was clicked." );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Written by Rob van der Woude" );

			Console.Error.WriteLine( "http://www.robvanderwoude.com" );

			return 1;
		}
	}
}
