#! /home/kappa/bin/perl6
use v6;

my $N_ROOMS = 25;
my @ROOMS = 0 .. $N_ROOMS - 1;

my @cave_mat;

my (Int $player, Int $wumpus, @cave);
my (@bats, @pits);

# ========================================

create_cave();

loop {
    # 0. check
    if $player == $wumpus {
        die "You are eaten";
    }

    if $player == any(@pits) {
        die "You fall into a pit";
    }

    if $player == any(@bats) {
        say "You are carried away by bats";
        $player = @ROOMS.pick;
        redo;
    }

    # 1. report
    say "You are in room $player";
    say "  (wumpus sleeps in $wumpus)";
    say "  (bat are in {@bats})";
    say "  (pits are in {@pits})";
    say "You feel wind from a pit" if any(links($player)) == any @pits;
    say "You hear rustle from bats" if any(links($player)) == any @bats;
    say "You see passages to &links($player)";

    # 2. read
    my $cmd = prompt "Move or shoot [ms]: ";

    # 3. act
    $player = $cmd if $cmd == any(links($player));
}

# ========================================

sub create_cave {
    print "Generating cave";
    repeat {
        @cave_mat = map { [ 0 xx $N_ROOMS ] }, @ROOMS;

        my Int $next = @ROOMS.pick;
        for @ROOMS -> $room {
            my $n_links = links($room).elems;

            while $n_links < 3 {
                if linked($room, $next) || links($next).elems >= 3 {
                    $next = ($next + 1) % $N_ROOMS;
                    next;
                }

                dig_link($room, $next)
                    and ++$n_links;
                print ".";

                # XXX NEXT { $next = ($next + 1) % $N_ROOMS; }
            }

            #say "Links for room $room: ", ~links($room);
        }

        #say "Cave mat: ", join "\n", map { ~@($_) }, @cave_mat;
    } until coupled();

    say "complete!";

    $wumpus = @ROOMS.pick;
    $player = @ROOMS.pick;

    @bats = @ROOMS.pick(3);
    @pits = @ROOMS.pick(3);
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
        #say "top = $top, queue = @queue[]";

        push @queue, grep { !@connected[$_] }, links($top);

        $_ = 1 for @connected[@queue];
    }

    return [&&] @connected;
}
