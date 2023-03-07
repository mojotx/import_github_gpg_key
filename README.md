# Import GitHub GPG Key

## Description

This shell script queries the GitHub REST API and retrieves the GPG keys for a specified user, so that you can
validate their GPG-signed commits.

## Requirements

The shell script is written for Bash, and should run without modification on Linux, macOS, Microsoft
Windows Subsystem for Linux, and any other UNIX-like operating system that supports the following
executable commands:

- [curl](https://curl.se/)
- [jq](https://stedolan.github.io/jq/)
- [gnupg](https://gnupg.org/)

## Usage

You will need to create a GitHub token for authenticating with the GitHub
REST API. You can easily do that by going to [https://github.com/settings/tokens](https://github.com/settings/tokens).
Note that there is no need to specify any special permissions for this token; it's just used for the query.

Pass the generated token to the script as an environment variable, `$GITHUB_TOKEN`:

### Method One

You can set the environment variable in your shell, like this, before calling the script.

```sh
GITHUB_TOKEN="ghp_blahblahblahexampleblahblahblah"
./query-user.sh mojotx
```

### Method Two

You can also place the environment variable in a text file named `.github_token`,
and place it in the same directory as the script, or in your home directory.

```sh
echo 'GITHUB_TOKEN="ghp_blahblahblahwhateverblahblah"' > ~/.github_token
./query-user.sh mojotx
```

## Source

The API I use is documented [here](https://docs.github.com/en/rest/users/gpg-keys?apiVersion=2022-11-28#list-gpg-keys-for-a-user).

## License

This script is licensed under the [MIT License](https://opensource.org/license/mit/).
