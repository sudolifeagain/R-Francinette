# R-Francinette

A Linux/Docker compatible fork of [Francinette](https://github.com/xicodomingues/francinette), a 42 tester framework.

Use `raco` inside a project folder to run tests.

Currently has tests for: `libft`, `ft_printf`, `get_next_line`, `minitalk` and `pipex`.

## Changes from upstream

This fork fixes several issues that prevent Francinette from running on Linux (glibc/Docker):

- **malloc mock fix (fsoares)**: Replace `dlsym(RTLD_NEXT, "malloc")` with `__libc_malloc` / `__libc_free` to avoid infinite recursion on glibc (glibc's `dlsym` internally calls `malloc`)
- **malloc mock fix (printfTester)**: Same `__libc_malloc` fix for Tripouille's printfTester leak checker, plus `in_hook` guard to prevent `std::vector::push_back` → `malloc` recursion
- **leak_check_start marker (fsoares)**: Track only allocations made after ft_printf starts, avoiding false leak reports from glibc's internal stdio buffer allocations
- **pexpect fallback (BaseExecutor)**: Add subprocess.Popen fallback when `pexpect.spawn` fails in Docker containers (no pty available)
- **ASan removal (fsoares)**: Remove `-fsanitize=address` which conflicts with `__libc_malloc` on Linux

## Docker Installation (Dockerfile)

Add the following to your Dockerfile (Ubuntu 22.04):

```dockerfile
# Dependencies
RUN apt-get update && apt-get install -y --no-install-recommends     python3-dev python3-venv libbsd-dev libncurses-dev     && rm -rf /var/lib/apt/lists/*

# Clone and setup
RUN git clone --recursive https://github.com/sudolifeagain/R-Francinette.git /root/francinette &&     cd /root/francinette &&     bash bin/post_install.sh &&     python3 -m venv venv &&     . venv/bin/activate &&     pip3 install -r requirements.txt

# Environment
ENV TERM=xterm

# Alias
RUN echo 'alias raco=/root/francinette/tester.sh' >> /root/.zshrc &&     echo 'alias raco=/root/francinette/tester.sh' >> /root/.bashrc
```

Then mount your project workspace and run:

```bash
cd /path/to/your/printf   # or libft, get_next_line, etc.
raco
```

## Manual Installation (Linux)

```bash
# Install dependencies (Ubuntu/Debian)
sudo apt update
sudo apt install -y gcc clang python3-dev python3-pip python3-venv libbsd-dev libncurses-dev valgrind

# Clone
git clone --recursive https://github.com/sudolifeagain/R-Francinette.git ~/francinette

# Apply Linux patches
bash ~/francinette/bin/post_install.sh

# Setup Python venv
cd ~/francinette
python3 -m venv venv
. venv/bin/activate
pip3 install -r requirements.txt

# Add alias to your shell config
echo 'alias raco=~/francinette/tester.sh' >> ~/.bashrc
source ~/.bashrc
```

## Running

Run `raco` in a project directory that contains a `Makefile`:

```bash
cd ~/your-project/libft
raco                          # Run all tests

raco memset isalpha memcpy    # Run specific tests only
```

The tester auto-detects the project type from the `Makefile` (e.g., `NAME = libftprintf.a` → ft_printf tests).

## Acknowledgments

* [xicodomingues/francinette](https://github.com/xicodomingues/francinette) - Original project
* [Tripouille](https://github.com/Tripouille) - libftTester, gnlTester, printfTester
* [jtoty](https://github.com/jtoty) / [y3ll0w42](https://github.com/y3ll0w42) - libft-war-machine
* [alelievr](https://github.com/alelievr) - libft-unit-test, printf-unit-test
* [cacharle](https://github.com/cacharle) - ft_printf_test
* [vfurmane](https://github.com/vfurmane) - pipex-tester
* [gmarcha](https://github.com/gmarcha) - pipexMedic
