# LocalAuthentication-verify
A CLI tool to verify user's credential using Biometry, Watch or Password. Useful for other other apps wanting to use Local Authentication as a unlock method.

## Usage
LocalAuthentication-verify [arguments]

### Arguments
 * -s, --supports [policy]           Check if the policy is supported in this device (empty policy refears to deviceOwnerAuthentication)
 * -a, --authenticated [policy]      Authenticate using policy (empty policy refears to deviceOwnerAuthentication)

Where policy is a [LocalAuthentication Policy](https://developer.apple.com/documentation/localauthentication/lapolicy)

#### Policies and arguments mapping

The *policy* argument in this tool can take 4 values, each of them refers to an LocalAuthentication Policy as defined in Apple docs

 * withBiometrics          -> LAPolicy.deviceOwnerAuthenticationWithBiometrics
 * withWatch               -> LAPolicy.deviceOwnerAuthenticationWithWatch
 * withBiometricsOrWatch   -> LAPolicy.deviceOwnerAuthenticationWithBiometricsOrWatch
 * **(empty)**             -> LAPolicy.deviceOwnerAuthentication
 
For example, if you need to check if authentication with Watch is possible, you can execute

```sh
localauthentication-verify -s withWatch
```

Which can produce either of the following responses

```sh
Unsupported: No AppleWatch was discovered.
```

```sh
Supported
```

### Output and Status Code

All successful outputs (**supports** or **authenticate**) will produce an **exit code: 0** indicating success. And all outputs with errors will produce an **exit code: 1** indicating failure. By doing this, you don't need to parse the output string, just check the status code.

```sh
$ ./LocalAuthentication-verify -s withWatch
Unsupported: No AppleWatch was discovered.
$ echo $?
1
```

```sh
$ ./LocalAuthentication-verify -a          
Authenticated
$ echo $?
0
```

## References

* [LocalAuthentication](https://developer.apple.com/documentation/localauthentication/)
