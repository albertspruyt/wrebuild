#!/data/wre/prereqs/perl/bin/perl

use strict;
use Parse::PlainConfig;
use DBI;
use Net::FTP;

# get configuration
my $config = Parse::PlainConfig->new( 'DELIM' => '=', 'FILE' => '/data/wre/etc/backup.conf', 'PURGE' => 1);
my $backupDir = $config->get("backupDir");
my $tar = $config->get("tar");
my $rotate = $config->get("rotateBackups");

rotateBackupFiles($rotate,$backupDir) if ($rotate);
backupMysql($config->get("mysqluser"),$config->get("mysqlpass"),$backupDir,$config->get("mysqlhost"),$config->get("db-port")) if ($config->get("backupMysql"));
backupDomains($tar,$backupDir) if ($config->get("backupDomains"));
backupWebgui($tar,$backupDir) if ($config->get("backupWebgui"));
backupWre($tar,$backupDir) if ($config->get("backupWre"));
runExternalScripts($config->get("externalScripts"));
compressBackups($config->get("gzip"),$backupDir) if ($config->get("compressBackups"));
copyToFtp($config->get("ftphost"),$config->get("ftpuser"),$config->get("ftppass"),$config->get("ftpCopiesToKeep"),$config->get("ftpPassiveTransfers"),$backupDir) if ($config->get("backupToFtp"));


sub copyToFtp {
	my $host = shift;
	my $user = shift;
	my $pass = shift;
	my $copiesToKeep = shift;
	my $passive = shift;
	my $backupDir = shift;
	my $now = time;
	my $ftp = Net::FTP->new($host,Passive=>$passive);
	$ftp->login($user,$pass);
	my @dirs = $ftp->ls;
	@dirs = sort(@dirs);
	my $i = scalar(@dirs);
	foreach my $dir (@dirs) {
		last if ($i < $copiesToKeep);
		$ftp->rmdir($dir,1);
		$i--;
	}
	$ftp->mkdir($now);
	$ftp->quit;
	my $passivecmd = "";
	unless ($passive) {
		$passivecmd = "set ftp:passive-mode off; ";
	} 
	system('/data/wre/prereqs/utils/bin/lftp -e "'.$passivecmd.'mput -O '.$now.' '.$backupDir.'/*.gz; exit" -u '.$user.','.$pass.' ftp://'.$host.' > /dev/null');
}

sub rotateBackupFiles {
	my $numberOfRotations = shift;
	my $backupDir = shift;
	opendir(DIR,$backupDir);
	my @files = readdir(DIR);
	closedir(DIR);
	for (my $i = $numberOfRotations; $i > 0; $i--) {
		foreach my $file (@files) {
			if ($file =~ /(.*\.)$i$/) {
				my $filefront = $1;
				if ($i == $numberOfRotations) {
					unlink "$backupDir/".$file;
				} else {
					rename "$backupDir/".$file, "$backupDir/".$filefront.($i+1);
				}
			}
		}
	}
	foreach my $file (@files) {
		if ($file =~ /\.gz$/) {
			rename "$backupDir/".$file, "$backupDir/".$file.".1";
		}
	}
}

sub runExternalScripts {
	my $externalScripts = shift;
	my @scripts;
	if (ref $externalScripts eq "ARRAY") {
		@scripts = @{$externalScripts};
	} elsif ($externalScripts ne "") {
		push(@scripts,$externalScripts);
	}
	foreach my $script (@scripts) {
		system($script);
	}
}

sub backupDomains {
	my $tar = shift;
	my $backupDir = shift;
	opendir(DIR,"/data/domains");
	my @domains = readdir(DIR);
	closedir(DIR);
	foreach my $domain (@domains) {
		next if ($domain eq "." || $domain eq "..");
		system("$tar --exclude-from=/data/wre/etc/backup.exclude --create --file $backupDir/$domain.tar /data/domains/$domain");
	}
}

sub backupWre {
	my $tar = shift;
	my $backupDir = shift;
	system("$tar --exclude-from=/data/wre/etc/backup.exclude --create --file $backupDir/wre.tar /data/wre");
}

sub backupWebgui {
	my $tar = shift;
	my $backupDir = shift;
	system("$tar --exclude-from=/data/wre/etc/backup.exclude --create --file $backupDir/webgui.tar /data/WebGUI");
}

sub compressBackups {
	my $gzip = shift;
	my $backupDir = shift;
	system("$gzip -f $backupDir/*.sql");
	system("$gzip -f $backupDir/*.tar");
}

sub backupMysql {
	my $user = shift;
	my $pass = shift;
	my $backupDir = shift;
	my $host = shift;
	my $db_port = shift ;
	my $dsn = "DBI:mysql:mysql;host=$host" ;
	if ($db_port) {
		$dsn .= ";port=$db_port" ;
	}
	my $dbh = DBI->connect($dsn,$user,$pass);
	my $sth = $dbh->prepare("show databases");
	$sth->execute;
	my $cmd = "/data/wre/prereqs/mysql/bin/mysqldump --host=$host" ;
	if ($db_port) {
		$cmd .= " --port=$db_port" ;
	}
	while (my ($name) = $sth->fetchrow_array) {
		next if ($name =~ /^demo\d/);
		next if ($name =~ /^test$/);
		system($cmd . " -u".$user." -p".$pass." ".$name." > $backupDir/".$name.".sql");
	}
	$sth->finish;
	$dbh->disconnect;
}

