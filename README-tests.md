# Puppet Tests

## Setup

In order to be able to run the tests, you must install bundler:

```bash
sudo gem install bundler
```

Then to run the tests you must call the `run-tests.sh` script or just use this command

```bash
rake spec
```

## Git hook

In order to make git run the tests before any commit, follow these steps:

```bash
mkdir .git/hooks
cd .git/hooks
ln -sf ../../run-tests.sh pre-commit
ls -lv # verify link is correctly created
cat pre-commit # verify it contains the script that calls rake spec
```

Done! now everytime you make a commit it will run the tests and abort the commit if the tests fail!
