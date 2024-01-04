mkdir -p /usr/jails/freebsd32
cp build.nims /usr/jails/freebsd32/
cp -R patches /usr/jails/freebsd32/
cp -R new /usr/jails/freebsd32/
cd /usr/jails/freebsd32 || exit
fetch ftp://ftp2.de.freebsd.org/pub/FreeBSD/releases/i386/i386/14.0-RELEASE/base.txz
tar xf base.txz
rm -rf boot
rm base.txz
cp /etc/resolv.conf /usr/jails/freebsd32/etc/
sed -i '' -e 's/quarterly/latest/g' /usr/jails/freebsd32/etc/pkg/FreeBSD.conf
jail -c -f /root/work/wine-freesbie/wine-freesbie/jail.conf freebsd32
jexec freebsd32 pkg install -y git nim ca_root_nss
jexec freebsd32 git clone https://github.com/freebsd/freebsd-ports.git /usr/ports
jexec freebsd32 touch output.txt
jexec freebsd32 /usr/local/nim/bin/nim --hints:off build.nims "$1" "$2"
jexec freebsd32 cp output.txt /
jexec freebsd32 cp work/pkg/*.pkg /
cp /usr/jails/freebsd32/output.txt /root/work/wine-freesbie/wine-freesbie/
cp /usr/jails/freebsd32/*.pkg /root/work/wine-freesbie/wine-freesbie/
