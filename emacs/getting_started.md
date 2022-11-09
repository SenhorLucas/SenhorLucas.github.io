# Emacs setup the right way

It took me more than a month to install and setup Emacs in a way that does not
feel hacky. That almost discouraged me to continue using Emacs, but the idea of
using Lisp instead of Vim Script is too tempting to ignore, so I persevered.
Luckily so: now I have a bullet proof setup on my Ubuntu machine!


## Installation

I am running on Ubuntu 22.04, and the Emacs version available is 27.1. Fine,
let's go with it even though the newer, shinier Emacs 28 is available in the PPA
repository closest to your home (`ppa:kellyk/emacs`, sorry Kelly K., we won't
trust that).

    sudo apt install emacs

Done.


## Server mode
And then server mode was touted as the way to go, and it was not hard to
convince me. Having a persistent Emacs session that will surviving SSH mishaps
will make me feel at home, specially because I currently use Tmux.

But rewinding a bit, what is server mode?

When run Emacs by simply running `emacs`, a new Emacs process starts on your
computer. So if you run it 3 times, you get 3 processes:

```

▶ emacs &
[1] 567446

▶ emacs &
[2] 567663

▶ emacs &
[3] 567879

▶ ps aux | grep emacs
lviana    567446  7.3  1.0 910268 159472 pts/7   SNl  12:47   0:02 emacs
lviana    567663  9.0  0.9 878428 155336 pts/7   SNl  12:47   0:02 emacs
lviana    567879 12.7  0.9 1023404 151992 pts/7  SNl  12:48   0:02 emacs
```

This starts 3 new emacs frames. If you close any of them, then that session is
gone. If you had anything important there, too bad, it's gone. Also, if you have
some extremely heavy emacs config, it might take a couple of seconds to load all
your plugins, etc. and that might kill your workflow.

Instead, we can do things a little differently:

```
▶ emacs --daemon

▶ emacsclient -c &
[1] 575547

▶ emacsclient -c &
[2] 579339

▶ ps aux | grep emacs
lviana    553632  0.6  0.8 1009760 138828 ?      Ssl  12:39   0:06 /usr/bin/emacs --fg-daemon
lviana    575547  0.0  0.0   2792   976 pts/7    SN   12:52   0:00 emacsclient -c
lviana    579339  0.0  0.0   2792   996 pts/7    SN   12:55   0:00 emacsclient -c
```

This also opens a couple of Emacs sessions, but you will notice something
magical happening: whatever you do in one frame also happens in the other frame
-- they mirror each other exactly! So what is happening is that you only have
one Emacs session running (`emacs --daemon`), and this session is running in the
background. If you want to see it, you need to attach to it via `emacsclient
-c`. So the `emacsclient` command does not start Emacs itself, it simply creates
a visible frame through which you can see the daemon.

The main benefit of this is that you may close your emacs frames wihout really
quitting Emacs itself: when you reopen Emacs it will be exactly as you left off.


## Socket location

Whenever there is a service running as a daemon and a client that wants to talk
to it, there is always a socket involved. On Emacs 27 this location is
`${XDG_RUNTIME_DIR}/emacs/service`, which translates to
`/run/user/1000/emacs/service` on my system.


## Systemd
When you install Emacs, you might get this file:

    /usr/lib/systemd/user/emacs.service

If not, create it at `~/.config/systemd/user/emacs.service`:

    [Unit]
    Description=Emacs text editor
    Documentation=info:emacs man:emacs(1) https://gnu.org/software/emacs/

    [Service]
    Type=forking
    ExecStart=/usr/bin/emacs --daemon
    ExecStop=/usr/bin/emacsclient --eval "(kill-emacs)"
    Environment=SSH_AUTH_SOCK=%t/keyring/ssh
    Restart=on-failure

    [Install]
    WantedBy=default.target

So now instead of running `emacs --daemon` you can conveniently run:

    systemd --user start emacs

Well, that's not better, but wait! You will never have to start the server
directly. Let me explain.

What we are trying to accomplish is called socket activation. We let systemd
create the socket file for us **without starting the emacs daemon**. systemd
will listen on this socket silently, in the background, doing nothing if nothing
arrives in the socket. However, if we run `emacsclient -c` systemd will see
traffic in the socket and then it will bring up `emacs --daemon`. See, using the
socket activates the daemon: "Thou shalt wake up!" Once Emacs is up, systemd
hands over the socket to the daemon so it can see what the client asked it to
do.

But how do we tell systemd to create the socket? And how does it know that it
should start the Emacs daemon?

All you need to do is to create the file
`/home/lviana/.config/systemd/user/emacs.socket` with contents:

    [Unit]
    Description=Socket for starting the Emacs server

    [Socket]
    ListenStream=/run/user/1000/emacs/server
    SocketMode=770

    [Install]
    WantedBy=sockets.target

And then let systemd know that it should create the socket on startup:

    systemd --user load emacs.socket

And don't wait untill the next boot. Create the socket immediately:

    systemd --user start emacs.socket

So now systemd has 2 units called `emacs`, and one of them is a service and
another one is a socket. Because those units have the same name systemd knows
that the socket activates the service. It is a bit of background magic at work.

Now, after all this effort we can start emacs like this:

    emacsclient -c

And the chain of events is as follows:

0. You start your computer and systemd creates a socket, and waits for someone
   to try to send something into it.
1. `emacsclient` sends something into the socket
2. systemd detects that someone is talking into the socket
3. systemd starts `emacs.service`
4. `emacs --daemon` runs and takes over the socket
5. `emacsclient` talks to the daemon and tells it that we should `-c` create a
   frame.

If you want to free some resources in your machine you can stop the daemon and
go back to 0:

    systemd --user stop emacs

This stops `emacs.service` using the `ExecStop` command as specified in the
service file.

    ExecStop=/usr/bin/emacsclient --eval "(kill-emacs)"


## Caveat

When writing the socket unit file we needed to hard code the path to the socket.
Ideally it would have been possible to use `${XDG_RUNTIME_DIR}`, but variable
expansions like that do not work in systemd unit files. That's quite bad.

## Was it worth it

I am not sure yet. Simply starting Emacs by typing `emacs` is extremely simple
and always works. There are no sockets and reopening some buffers might not be
so painful. So maybe starting Emacs as a daemon was a total waste of time and
the payback will never come. Remains to be seen. This is the first time I write
a systemd socket activated service, so I will consider the time invested in
learning, rather than actually gaining so much in the workflow.
