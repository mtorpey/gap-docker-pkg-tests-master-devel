# Function to test package
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