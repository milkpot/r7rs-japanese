%order = ();
%main = ();
%aux = ();

open(F, "<r7rs.idx");
while (<F>) {
  chomp;
  if (/^"(.+)" "(.+)" (main|aux) ([0-9]+)$/) {
    $text = $1;
    $cmd = $2;
    $type = $3;
    $page = $4;
    $text =~ s/\\(.)/$1/g;
    $key = "\\$cmd\{$text\}";
    $x = $text;
    $x =~ tr/A-Z/a-z/;
    $head = substr($x, 0, 1);
    if ($cmd eq "sharpfoo") {
      $x = "#" . $x;
    }
    if ($text =~ /^[A-Za-z]/) {
      $i = "$head $x $text $cmd";
    } elsif ($text lt "\x7f") {
      $i = "\x20 $x $text $cmd";
    } else {
      $i = "\x7f $x $text $cmd";
    }
    $order{$i} = $key;
    if ($type eq "main") {
      $main{$key} .= "$page,";
    } else {
      $aux{$key} .= "$page,";
    }
  }
}
close(F);

$head = "";

open(F, ">index.tex");
for $i (sort(keys(%order))) {
  $key = $order{$i};
  $h = substr($i, 0, 1);
  if ($head ne $h && $h ge "a") {
    $head = $h;
    print F "\\indexspace\n";
  }
  @main = split(/,/, $main{$key});
  @aux = split(/,/, $aux{$key});
  @main = sort{$a<=>$b}(@main);
  @aux = sort{$a<=>$b}(@aux);
  @page = (@main, @aux);
  $main = shift(@page);
  $key =~ s/([_#])/\\$1/g;
  print F "\\item{$key}{\\hskip .75em}\\hyperlink{page.$main}{$main}";
  %page = ();
  for $page (@page) {
    $page{$page} = 1;
  }
  delete $page{$main};
  @page = sort{$a<=>$b}(keys(%page));
  if (@page > 0) {
    $page = shift(@page);
    print F "; \\hyperlink{page.$page}{$page}";
    while (@page > 0) {
      $page = shift(@page);
      print F ", \\hyperlink{page.$page}{$page}";
    }
  }
  print F "\n";
}
close(F);
