case $PERL_CONFIG_SH in
'')
	if test -f config.sh; then TOP=.;
	elif test -f ../config.sh; then TOP=..;
	elif test -f ../../config.sh; then TOP=../..;
	elif test -f ../../../config.sh; then TOP=../../..;
	elif test -f ../../../../config.sh; then TOP=../../../..;
	else
		echo "Can't find config.sh."; exit 1
	fi
	. $TOP/config.sh
	;;
esac
: This forces SH files to create target in same directory as SH file.
: This is so that make depend always knows where to find SH derivatives.
case "$0" in
*/*) cd `expr X$0 : 'X\(.*\)/'` ;;
esac
echo "Extracting writemain (with variable substitutions)"
: This section of the file will have variable substitutions done on it.
: Move anything that needs config subs from !NO!SUBS! section to !GROK!THIS!.
: Protect any dollar signs and backticks that you do not want interpreted
: by putting a backslash in front.  You may delete these comments.
rm -f writemain
$spitshell >writemain <<!GROK!THIS!
$startsh
!GROK!THIS!

: In the following dollars and backticks do not need the extra backslash.
$spitshell >>writemain <<'!NO!SUBS!'
# This script takes the plain miniperlmain.c and writes out perlmain.c
# which includes all the extensions.
# The command line arguments name extensions to be used.
#  E.g.:  sh writemain SDBM_File POSIX > perlmain.c
#

orig="$*"
args=''
: Remove any .a suffixes and any leading path components
for file in $orig ; do
	file=`echo $file | sed -s 's!^\(ext\|dist\|cpan\|lib\)/!!'`
	args="$args $file"
done


sed '/Do not delete this line--writemain depends on it/q' miniperlmain.c


if test X"$args" != "X" ; then
    for ext in $args ; do
: $ext will either be 'Name' or 'Name1-Name2' etc
: convert ext into cname and mname
mname=`echo $ext   | sed 's!-!::!g'`
cname=`echo $mname | sed 's!:!_!g'`

echo "EXTERN_C void boot_${cname} (pTHX_ CV* cv);"
    done
fi

cat << 'EOP'

static void
xs_init(pTHX)
{
EOP

if test X"$args" != "X" ; then
    echo "    static const char file[] = __FILE__;"
    echo "    dXSUB_SYS;"

    ai=''

    for ext in $args ; do

	: $ext will either be 'Name' or 'Name1/Name2' etc
	: convert ext into cname and mname
	mname=`echo $ext   | sed 's!-!::!g'`
	cname=`echo $mname | sed 's!:!_!g'`

	if test "$ext" = "DynaLoader"; then
	    : Must NOT install 'DynaLoader::boot_DynaLoader' as 'bootstrap'!
	    : boot_DynaLoader is called directly in DynaLoader.pm
	    echo "        newXS(\"${mname}::boot_${ext}\", boot_${cname}, file);"
	else
	    echo "        newXS(\"${mname}::bootstrap\", boot_${cname}, file);"
	fi
    done
fi

cat << 'EOP'
}
EOP

!NO!SUBS!
chmod 755 writemain
$eunicefix writemain
