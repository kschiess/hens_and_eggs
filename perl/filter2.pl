open FILTER, "|svnserve -t|" or die $!;
my @resp = <FILTER>;
print @resp;

print FILTER "()";

