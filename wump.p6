#! /home/kappa/bin/perl6
use v6;

my $N_ROOMS = 25;
my @ROOMS = 0 .. $N_ROOMS - 1;

my @cave_mat;

my (Int $player, Int $wumpus, @cave);

# ========================================

create_cave();

say "Cave created";

loop {
    # 0. check
    if $player == $wumpus {
        die "You are eaten";
    }

    # 1. report
    say "You are in $player (wumpus sleeps in $wumpus)";
    say "You can go to &links($player)";

    # 2. read
    my $cmd = prompt "Move?";

    # 3. act
    $player = $cmd if $cmd == any(links($player));
}

# ========================================


sub create_cave {
    @cave_mat = map { [ 0 xx $N_ROOMS ] }, @ROOMS;

    my Int $next = $N_ROOMS.rand.Int;
    for @ROOMS -> $room {
        my $n_links = links($room).elems;

        while $n_links < 3 {
            if linked($room, $next) || links($next).elems >= 3 {
                $next = ($next + 1) % $N_ROOMS;
                next;
            }

            dig_link($room, $next)
                and ++$n_links;

            # XXX NEXT { $next = ($next + 1) % $N_ROOMS; }
        }

        say "Links for room $room: ", ~links($room);
    }

    say "Cave mat: ", join "\n", map { ~@($_) }, @cave_mat;

    die unless coupled();

    $wumpus = int ($N_ROOMS + 1).rand;
    $player = int ($N_ROOMS + 1).rand;
}

sub linked($from, $to) {
    return @cave_mat[$from][$to];
}

sub dig_link($from, $to) {
    @cave_mat[$from][$to] = @cave_mat[$to][$from] = 1;
}

sub links($from) {
    return grep { @cave_mat[$from][$_] }, @ROOMS;
}

sub coupled {
    my @queue = (0,);
    my @connected = 0 xx $N_ROOMS;
    @connected[@queue[0]] = 1;

    while defined (my $top = @queue.shift) {
        say "top = $top, queue = @queue[]";

        push @queue, grep { !@connected[$_] }, links($top);

        $_ = 1 for @connected[@queue];
    }

    return [&&] @connected;
}
