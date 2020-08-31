package Forker;

# Author: Martin Falkmer, mf881899

use strict;
use Data::Dumper;

$SIG{CHLD} = 'IGNORE';

sub new {
    my $self = shift;

    my %args = (
        kids        => [],
        pids        => [],
        output      => [],
        threads     => undef,
        filehandle  => undef,
        save_output => undef,
        waitprint   => undef,
        @_,
    );

    return bless \%args, $self;
}

sub AddFork {
    no warnings "exiting";
    my ($self, $fork) = @_;

    if ($self->{threads} && scalar(grep {kill(0,$_)} @{$self->{pids}}) >= $self->{threads}) {
        sleep 1 until scalar(grep {kill(0,$_)} @{$self->{pids}}) < $self->{threads};
    }

    if (!$self->{waitprint}) {
        $self->_PrintFork();
    }

    push @{$self->{kids}}, {
        'fork' => $fork || ""
    };

    defined(my $pid = open $self->{kids}->[$#{$self->{kids}}]->{pid}, "-|") or print "Failed to fork\n" and pop @{$self->{kids}} and next;
    push @{$self->{pids}}, $pid and next if $pid;
}

sub _PrintFork {
    my $self = shift;

    while (scalar @{$self->{kids}}) {
        last if kill(0,$self->{pids}->[0]);
        my $pid = shift @{$self->{kids}};
        shift @{$self->{pids}};
        $self->_Print($pid);
    }
}

sub _Print {
    my ($self, $pid) = @_;

    if ($self->{save_output}) {
        my $output = $pid->{pid};
        $pid->{pid} = <$output>;
        push @{$self->{output}}, $pid;
    }
    else {
        $pid = $pid->{pid};
        print { $self->{filehandle} || *STDOUT } <$pid>;
    }
}

sub Finish {
    my $self = shift;

    while (my $pid = shift @{$self->{kids}}) {
        waitpid 0, $pid->{pid};
        $self->_Print($pid);
    }
}

1;
