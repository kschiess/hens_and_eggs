open FILTER, "|svnserve -t" or die $!;
# print FILTER $input;
my @resp = <FILTER>;
close FILTER;
print @resp