@echo off

set pass=Magik1908

dsadd ou "ou=Tesztelok, dc=dolgozat, dc=local"
dsadd group "cn=tesztelok, ou=Tesztelok, dc=dolgozat, dc=local"

dsadd ou "ou=Ellenorok, dc=dolgozat, dc=local"
dsadd group "cn=ellenorok, ou=Ellenorok, dc=dolgozat, dc=local"

setlocal enableextensions enabledelayedexpansion
	dsadd user "CN=tesztelo1, OU=Tesztelok, dc=dolgozat,dc=local" -pwd %pass% -pwdneverexpires yes -samid tesztelo1 -upn tesztelo1 -memberof "cn=tesztelok, ou=Tesztelok, dc=dolgozat, dc=local"
	dsmod user "CN=tesztelo1, OU=Tesztelok, dc=dolgozat,dc=local" -disabled no
	dsadd user "CN=tesztelo2, OU=Tesztelok, dc=dolgozat,dc=local" -pwd %pass% -pwdneverexpires yes -samid tesztelo2 -upn tesztelo2 -memberof "cn=tesztelok, ou=Tesztelok, dc=dolgozat, dc=local"
	dsmod user "CN=tesztelo2, OU=Tesztelok, dc=dolgozat,dc=local" -disabled no

	dsadd user "CN=ellenor1, OU=Ellenorok, dc=dolgozat,dc=local" -pwd %pass% -pwdneverexpires yes -samid ellenor1 -upn ellenor1 -memberof "cn=ellenorok, ou=Ellenorok, dc=dolgozat, dc=local"
	dsmod user "CN=ellenor1, OU=Ellenorok, dc=dolgozat,dc=local" -disabled no
	dsadd user "CN=ellenor2, OU=Ellenorok, dc=dolgozat,dc=local" -pwd %pass% -pwdneverexpires yes -samid ellenor2 -upn ellenor2 -memberof "cn=ellenorok, ou=Ellenorok, dc=dolgozat, dc=local"
	dsmod user "CN=ellenor2, OU=Ellenorok, dc=dolgozat,dc=local" -disabled no


endlocal