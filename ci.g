# Functions to test package
#

# Getting package name from its PackageInfo.g file
#
# Borrowed from `ValidatePackageInfo` in GAP's lib/package.gi
GetNameFromPackageInfo := function(info)
local record, pkgdir, i;

if IsString( info ) then
  if IsReadableFile( info ) then
	Unbind( GAPInfo.PackageInfoCurrent );
	Read( info );
	if IsBound( GAPInfo.PackageInfoCurrent ) then
	  record:= GAPInfo.PackageInfoCurrent;
	  Unbind( GAPInfo.PackageInfoCurrent );
	else
	  Error( "the file <info> is not a `PackageInfo.g' file" );
	fi;
	pkgdir:= "./";
	for i in Reversed( [ 1 .. Length( info ) ] ) do
	  if info[i] = '/' then
		pkgdir:= info{ [ 1 .. i ] };
		break;
	  fi;
	od;
  else
	Error( "<info> is not the name of a readable file" );
  fi;
elif IsRecord( info ) then
  pkgdir:= fail;
  record:= info;
else
  Error( "<info> must be either a record or a filename" );
fi;

return record.PackageName;

end;

# Running standard test for the package
#
TestOnePackage := function(pkgname)
local testfile, str;
if not IsBound( GAPInfo.PackagesInfo.(pkgname) ) then
    Print("#I  No package with the name ", pkgname, " is available\n");
    return fail;
elif LoadPackage( pkgname ) = fail then
    Print( "#I ", pkgname, " package can not be loaded\n" );
    return fail;
elif not IsBound( GAPInfo.PackagesInfo.(pkgname)[1].TestFile ) then
    Print("#I No standard tests specified in ", pkgname, " package, version ",
          GAPInfo.PackagesInfo.(pkgname)[1].Version,  "\n");
    return fail;
else
    testfile := Filename( DirectoriesPackageLibrary( pkgname, "" ), 
                          GAPInfo.PackagesInfo.(pkgname)[1].TestFile );
    str:= StringFile( testfile );
    if not IsString( str ) then
        Print( "#I Test file `", testfile, "' for package `", pkgname, 
        " version ", GAPInfo.PackagesInfo.(pkgname)[1].Version, " is not readable\n" );
        return fail;
    fi;
    if EndsWith(testfile,".tst") then
        if Test( testfile, rec(compareFunction := "uptowhitespace") ) then
            Print( "#I  No errors detected while testing package ", pkgname,
                   " version ", GAPInfo.PackagesInfo.(pkgname)[1].Version, 
                   "\n#I  using the test file `", testfile, "'\n");
            return true;       
        else
            Print( "#I  Errors detected while testing package ", pkgname, 
                   " version ", GAPInfo.PackagesInfo.(pkgname)[1].Version, 
                   "\n#I  using the test file `", testfile, "'\n");
            return false;
        fi;
    elif not READ( testfile ) then
        Print( "#I Test file `", testfile, "' for package `", pkgname,
        " version ", GAPInfo.PackagesInfo.(pkgname)[1].Version, " is not readable\n" );
    fi;
fi;
end;