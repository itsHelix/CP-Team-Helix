using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;


namespace RobvanderWoude
{
	class FontSelectBox
	{
		static string progver = "1.01";


		static int Main( string[] args )
		{
			#region Initialize Variables

			int rc = -1;

			float initialfontsize = 12;
			int maxsize = 48;
			int minsize = 6;

			string initialfontname = "Courier New";
			string returnproperty = "none";
			string showproperty = "all";

			bool allowscriptchange = false;
			bool allowvectorfonts = false;
			bool fixedpitchonly = false;
			bool scriptsonly = false;
			bool showcolor = false;
			bool showeffects = false;

			#endregion Initialize Variables


			#region Command Line Parsing

			foreach ( string arg in args )
			{
				if ( arg.Length > 1 && arg[0] == '/' )
				{
					if ( arg.Contains( ":" ) )
					{
						string key = arg.ToUpper( ).Substring( 1, arg.IndexOf( ':' ) - 1 );
						string val = arg.Substring( arg.IndexOf( ':' ) + 1 );
						switch ( key )
						{
							case "I":
								if ( initialfontsize != 12 )
								{
									return ShowHelp( "Duplicate initial font size {0}", arg );
								}
								try
								{
									initialfontsize = Convert.ToSingle( val );
								}
								catch ( Exception )
								{
									return ShowHelp( "Invalid initial font size {0}", arg );
								}
								break;
							case "MAX":
								if ( maxsize != 48 )
								{
									return ShowHelp( "Duplicate maximum font size {0}", arg );
								}
								try
								{
									maxsize = Convert.ToInt32( val );
								}
								catch ( Exception )
								{
									return ShowHelp( "Invalid maximum font size {0}", arg );
								}
								break;
							case "MIN":
								if ( minsize != 6 )
								{
									return ShowHelp( "Duplicate minimum font size {0}", arg );
								}
								try
								{
									minsize = Convert.ToInt32( val );
									if ( minsize < 1 )
									{
										return ShowHelp( "Invalid minimum font size {0}", arg );
									}
								}
								catch ( Exception )
								{
									return ShowHelp( "Invalid minimum font size {0}", arg );
								}
								break;
							case "P":
								if ( showproperty != "all" )
								{
									return ShowHelp( "Duplicate command line switch /P" );
								}
								switch ( val.ToUpper( ) )
								{
									case "CHARSET":
									case "COLOR":
									case "NAME":
									case "RGB":
									case "SIZE":
									case "STYLE":
										showproperty = val.ToLower( );
										break;
									default:
										return ShowHelp( "Invalid command line argument {0}", arg );
								}
								break;
							case "R":
								if ( returnproperty != "none" )
								{
									return ShowHelp( "Duplicate command line switch /R" );
								}
								switch ( val.ToUpper( ) )
								{
									case "C":
									case "R":
									case "S":
									case "Y":
										returnproperty = val.ToLower( );
										break;
									default:
										return ShowHelp( "Invalid command line argument {0}", arg );
								}
								break;
							default:
								return ShowHelp( "Invalid command line argument {0}", arg );
						}
					}
					else if ( arg.Length == 2 )
					{
						switch ( arg.ToUpper( )[1] )
						{
							case '?':
								return ShowHelp( );
							case 'C':
								if ( showcolor )
								{
									return ShowHelp( "Duplicate command line switch /C" );
								}
								showcolor = true;
								break;
							case 'E':
								if ( showeffects )
								{
									return ShowHelp( "Duplicate command line switch /E" );
								}
								showeffects = true;
								break;
							case 'H':
								if ( scriptsonly )
								{
									return ShowHelp( "Duplicate command line switch /H" );
								}
								scriptsonly = true;
								break;
							case 'S':
								if ( allowscriptchange )
								{
									return ShowHelp( "Duplicate command line switch /S" );
								}
								allowscriptchange = true;
								break;
							case 'V':
								if ( allowvectorfonts )
								{
									return ShowHelp( "Duplicate command line switch /V" );
								}
								allowvectorfonts = true;
								break;
							case 'X':
								if ( fixedpitchonly )
								{
									return ShowHelp( "Duplicate command line switch /X" );
								}
								fixedpitchonly = true;
								break;
							default:
								return ShowHelp( "Invalid command line switch {0}", arg.ToUpper( ) );
						}
					}
					else
					{
						return ShowHelp( "Invalid command line argument {0}", arg );
					}
				}
				else
				{
					if ( initialfontname != "Courier New" )
					{
						return ShowHelp( "Duplicate font name argument" );
					}
					initialfontname = arg;
				}
			}

			if ( maxsize < minsize )
			{
				return ShowHelp( "Maximum font size ({0}) must be greater than minimum font size ({1})", maxsize.ToString( ), minsize.ToString( ) );
			}
			if ( maxsize < initialfontsize || minsize > initialfontsize )
			{
				return ShowHelp( "Initial font size ({0}) must be in range {1}..{2}", initialfontsize.ToString( ), minsize.ToString( ), maxsize.ToString( ) );
			}

			#endregion Command Line Parsing


			Font font = new Font( initialfontname, initialfontsize );
		
			FontDialog fontdialog = new FontDialog
			{
				AllowScriptChange = allowscriptchange,
				AllowVectorFonts = allowvectorfonts,
				AllowVerticalFonts = false,
				FixedPitchOnly = fixedpitchonly,
				Font = font,
				FontMustExist = true,
				MaxSize = maxsize,
				MinSize = minsize,
				ScriptsOnly = scriptsonly,
				ShowApply = false,
				ShowColor = showcolor,
				ShowEffects = showeffects,
			};
						
			if ( fontdialog.ShowDialog( ) == DialogResult.OK )
			{
				int charset = fontdialog.Font.GdiCharSet;
				int rgb = ( fontdialog.Color.R * 256 + fontdialog.Color.G ) * 256 + fontdialog.Color.B;
				int size = Convert.ToInt32( fontdialog.Font.Size );
				int style = (int) fontdialog.Font.Style;
				switch ( showproperty )
				{
					case "charset":
						Console.WriteLine( "{0} ({1})", Enum.GetName( typeof( FontCharSet ), charset ), charset );
						break;
					case "color":
						Console.WriteLine( fontdialog.Color.Name );
						break;
					case "name":
						Console.WriteLine( fontdialog.Font.Name );
						break;
					case "rgb":
						Console.WriteLine( "{0},{1},{2} (0x{3,6:x6})", fontdialog.Color.R, fontdialog.Color.G, fontdialog.Color.B, rgb );
						break;
					case "size":
						Console.WriteLine( fontdialog.Font.Size );
						break;
					case "style":
						Console.WriteLine( "{0} ({1})", fontdialog.Font.Style, style );
						break;
					default:
						Console.WriteLine( "Font Name     : {0}", fontdialog.Font.Name );
						Console.WriteLine( "Font Size     : {0}", fontdialog.Font.Size );
						Console.WriteLine( "Font Style    : {0} ({1})", fontdialog.Font.Style, style );
						Console.WriteLine( "Font Color    : {0}", fontdialog.Color.Name );
						Console.WriteLine( "RGB Color     : {0},{1},{2} (0x{3,6:x6})", fontdialog.Color.R, fontdialog.Color.G, fontdialog.Color.B, rgb );
						Console.WriteLine( "Character Set : {0} ({1})", Enum.GetName( typeof( FontCharSet ), charset ), charset );
						break;
				}

				switch ( returnproperty )
				{
					case "c":
						rc = charset;
						break;
					case "r":
						rc = rgb;
						break;
					case "s":
						rc = size;
						break;
					case "y":
						rc = style;
						break;
					default:
						rc = 0;
						break;
				}
			}


			return rc;
		}


		static int ShowHelp( params string[] errmsg )

		{
			/*
			FontSelectBox.exe,  Version 1.00
			Batch tool to present a Font Select dialog and return selected font properties
 
			Usage:    FONTSELECTBOX  [ fontname ]  [ options ]  [ /R:return ]
 
			Where:    fontname     initial font name (default: Courier New)

			Options:  /I:size      Initial font size (default: 12)
			          /MAX:size    Maximum font size (default: 48)
			          /MIN:size    Minimum font size (default:  6)
			          /P:property  show only the requested Property for the selected font
			                       on screen, instead of "all" properties; property can be
			                       "Name", "Size", "Style", "Color", "RGB" or "CharSet"
			          /C           allow Color change (requires /E)
			          /E           allow Effects (e.g. strikeout and underline)
			          /H           allow "script" fonts only, no symbols
			          /S           allow Script (character set) change
			          /V           allow Vector fonts
			          /X           allow fiXed pitch fonts only

			Return:   default      return code 0 on valid selection, -1 on cancel or error
			          /R:C         Return code equals selected Character set number
			          /R:R         Return code equals RGB value of selected color
			          /R:S         Return code equals selected font Size (rounded)
			          /R:Y         Return code equals selected stYle: Regular = 0,
			                       Bold + 1, Italic + 2, Underline + 4, Strikeout + 8
			                       e.g. return code 7 means Bold + Italic + Underline
 
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


			#region Help Text

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "FontSelectBox.exe,  Version {0}", progver );

			Console.Error.WriteLine( "Batch tool to present a Font Select dialog and return selected font properties" );

			Console.Error.WriteLine( );

			Console.Error.Write( "Usage:    " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.WriteLine( "FONTSELECTBOX  [ fontname ]  [ options ]  [ /R:return ]" );
			Console.ResetColor( );

			Console.Error.WriteLine( );

			Console.Error.Write( "Where:    " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "fontname" );
			Console.ResetColor( );
			Console.Error.WriteLine( "     initial font name (default: Courier New)" );

			Console.Error.WriteLine( );

			Console.Error.Write( "Options:  " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/I:size      I" );
			Console.ResetColor( );
			Console.Error.WriteLine( "nitial font size (default: 12)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /MAX:size    Max" );
			Console.ResetColor( );
			Console.Error.WriteLine( "imum font size (default: 48)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /MIN:size    Min" );
			Console.ResetColor( );
			Console.Error.WriteLine( "imum font size (default:  6)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /P:property" );
			Console.ResetColor( );
			Console.Error.Write( "  show only the requested " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "P" );
			Console.ResetColor( );
			Console.Error.WriteLine( "roperty for the selected font" );

			Console.Error.Write( "                       on screen, instead of \"all\" properties; " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "property" );
			Console.ResetColor( );
			Console.Error.WriteLine( " can be" );

			Console.Error.WriteLine( "                       \"Name\", \"Size\", \"Style\", \"Color\", \"RGB\" or \"CharSet\"" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /C" );
			Console.ResetColor( );
			Console.Error.Write( "           allow " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "C" );
			Console.ResetColor( );
			Console.Error.Write( "olor change (requires " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "/E" );
			Console.ResetColor( );
			Console.Error.WriteLine( ")" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /E" );
			Console.ResetColor( );
			Console.Error.Write( "           allow " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "E" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ffects (e.g. strikeout and underline)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /H" );
			Console.ResetColor( );
			Console.Error.WriteLine( "           allow \"script\" fonts only, no symbols" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /S" );
			Console.ResetColor( );
			Console.Error.Write( "           allow " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "S" );
			Console.ResetColor( );
			Console.Error.WriteLine( "cript (character set) change" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /V" );
			Console.ResetColor( );
			Console.Error.Write( "           allow " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "V" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ector fonts" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /X" );
			Console.ResetColor( );
			Console.Error.Write( "           allow fi" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "X" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ed pitch fonts only" );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Return:   default      return code 0 on valid selection, -1 on cancel or error" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /R:C         R" );
			Console.ResetColor( );
			Console.Error.Write( "eturn code equals selected " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "C" );
			Console.ResetColor( );
			Console.Error.WriteLine( "haracter set number" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /R:R         R" );
			Console.ResetColor( );
			Console.Error.Write( "eturn code equals " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "R" );
			Console.ResetColor( );
			Console.Error.WriteLine( "GB value of selected color" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /R:S         R" );
			Console.ResetColor( );
			Console.Error.Write( "eturn code equals selected font " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "S" );
			Console.ResetColor( );
			Console.Error.WriteLine( "ize (rounded)" );

			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "          /R:Y         R" );
			Console.ResetColor( );
			Console.Error.Write( "eturn code equals selected st" );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( "Y" );
			Console.ResetColor( );
			Console.Error.WriteLine( "le: Regular = 0," );

			Console.Error.WriteLine( "                       Bold + 1, Italic + 2, Underline + 4, Strikeout + 8" );

			Console.Error.WriteLine( "                       e.g. return code 7 means Bold + Italic + Underline" );

			Console.Error.WriteLine( );

			Console.Error.WriteLine( "Written by Rob van der Woude" );

			Console.Error.WriteLine( "http://www.robvanderwoude.com" );

			#endregion Help Text


			return -1;
		}
	}


	public enum FontCharSet : byte
	{
		ANSI = 0,
		Default = 1,
		Symbol = 2,
		Mac = 77,
		ShiftJIS = 128,
		Hangeul = 129,
		Johab = 130,
		GB2312 = 134,
		ChineseBig5 = 136,
		Greek = 161,
		Turkish = 162,
		Hebrew = 177,
		Arabic = 178,
		Baltic = 186,
		Russian = 204,
		Thai = 222,
		EastEurope = 238,
		OEM = 255,
	}
}
