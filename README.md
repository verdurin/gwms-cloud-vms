# glideinWMS Virtual Machine Bootstrap 

 This repository provides the sources for a service which bootstraps a glideinWMS
 pilot and the resources to automate the building of a VM configured with the 
 bootstrap service.

## Bootstrap Service

 The bootstrap service source and rpm specs are located in the pilot services
 directory.  The bootstrap service currently only supports cloud providers that 
 provide an EC2 style meta-data service.  Plans are in the works to support
 hepix/OpenNebula style user data services.

 The expected user data is in the form:

```
[Base64 encoded blob]####[additional arguments]
```

 or just a plaintext ini file.


 "####" was picked as a separator because it will never appear in the base64 
 encoded string and we will make it a rule that it won't appear in the any of the
 userdata, either the base64 encoded blob or the additional arguments.

 If a plain text ini file is sent as user data, then it is assumed that the VM is
 being started up in debug mode.  Essentially, the only option that matters in 
 this case is the disable_shutdown option.  This prevents the service from 
 shutting down the VM, allowing an admin or dev to ssh into the VM for debugging
 purposes.  An example ini file is listed below:

```ini
[glidein_startup]
args = blah
proxy_file_name = pilot_proxy
webbase= na

[vm_properties]
max_lifetime = 43200
contextualization_type = EC2
disable_shutdown = True
```

## VM Building

 I am using [BoxGrinder](http://boxgrinder.org/) to automate VM builds.  It is a
 tool that really has no comparison IMHO.  All related files are in the 
 boxgrinder directory.  The current BoxGrinder template (and only one 
 "guaranteed" to work at this time) is hcc-template.appl.  NOTE: you need to
 include a line that comments out the "requiretty" line in /etc/sudoers so that
 the pilot service can execute privileged commands via sudo.

 As of version 10.4, BoxGrinder has a couple of fatal bugs in it that will 
 prevent you from using the EC2 and S3 plugins to automatically build and push to
 Amazon.  The boxgrinder/patches directory contains several patches that fix 
 them.  John Hover from BNL kindly supplied these patches.

 To use boxginder's plugins you have to configure them in ~/.boxgrinder/config.
 The following is an example of the config I use (minus the credential 
 information of course).  Fill in the appropriate information for your setup.

```yaml
plugins:
  sl:
    format: raw      # Disk format to use. Default: raw.

  s3:
    access_key: <REDACTED>                                          # (required)
    secret_access_key: <REDACTED>                                   # (required)
    bucket: <Bucket Name>                                           # (required)
    account_number: XXXX-XXXX-XXXX                                  # (required)
    path: /                                                         # default: /
    cert_file: /path/to/cert-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.pem   # required only for ami type
    key_file: /path/to/pk-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.pem      # required only for ami type
    region: us-east-1                                               # amazon region to upload and register amis in; default: us-east-1
    snapshot: false                                                 # default: false
    overwrite: false                                                # default: false
    block-device-mapping: /dev/sdb=ephemeral0
```

 The actual command to run is:

```bash
boxgrinder-build hcc-template.appl --debug --trace -p ec2 -d ami
```

 If you have configured everything correctly and there are no build errors, you 
 will have an AMI uploaded, registered and ready to use in EC2.

 The VM will expect one of the following data formats in the user data:

