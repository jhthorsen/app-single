use strict;
use Test::More;
use Digest::MD5 'md5_hex';
use Time::HiRes 'usleep';

plan skip_all => 'Cannot run without linux?' if $^O ne 'linux';
plan skip_all => 'Cannot run without script/single' unless -x 'script/single';

my $command = 'sleep 1';
my $guard = 0;
my $id = md5_hex $command;
my %info;

if (fork) {
  diag "Waiting for /tmp/single-$id";
  usleep 1e3 until -r "/tmp/single-$id" or $guard++ > 1000;
  ok $guard < 1000, "info file created ($guard)";
  $ENV{ALREADY_RUNNING_STATUS} = 42;
  $ENV{SINGLE_SILENT} = !$ENV{HARNESS_IS_VERBOSE};
  system 'script/single', $command;
  is $? >> 8, 42, 'already running';
  local @ARGV = ("/tmp/single-$id");
  chomp and /(\w+):\s*(.*)/ and $info{$1} = $2 while(<>);
  like $info{pid}, qr{^\d+$}, 'got pid';
  is $info{command}, $command, 'got command';
  is $info{id}, $id, 'got id';
  like $info{started}, qr/\b\d{4}\b/, 'got started';
  diag "Waiting for $command ...";
  wait;
  is $?, 0, 'command exit';
}
else {
  exec 'script/single', $command;
  die $!;
}

done_testing;
