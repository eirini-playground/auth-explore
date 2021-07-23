In order to find out what are all the roles in current CF and what each role is authorized to do
we have prepared a script that parses the api docs sources in the `cloud_controller_ng` repo and
prints lines in the format `resource:action:role`

This raw data can be used to determine what actions are allowed and disallowed for each role and
to reason about whether RBAC is powerful enough to implement CF's authorization logic.

Unfortunately there are gotchas:

- There are a few operations that are annotated as `No authentication required`. These are not
  printed by the script

```
~/workspace/cloud_controller_ng main*
❯ rg "No authentication required"
docs/v3/source/includes/resources/info/_get.md.erb
40:No authentication required.

docs/v3/source/includes/resources/root/_v3_root.md.erb
29:No authentication required.

docs/v3/source/includes/resources/root/_global_root.md.erb
29:No authentication required.

```

- In the docs there is a role called `All Roles`. It needs to be interpreted as the list of all known roles.
- There is a role called `Other`. This specifies the result of the operation for unauthorized users, something like
  a special view for everyone who is not authorized.
- There are a couple of `**Note**` annotation in the docs that outline some further details

```
~/workspace/cloud_controller_ng main* 1h 16m 48s
❯ rg "\*\*Note\*\*"
docs/v3/source/includes/concepts/_lifecycles.md.erb
33:**Note**: This lifecycle is not supported on Cloud Foundry for Kubernetes.
88:**Note**: This lifecycle is not supported on Cloud Foundry for VMs.

docs/v3/source/includes/resources/routes/_delete_unmapped.md.erb
35:**Note**: `unmapped=true` is a required query parameter; always include it.

docs/v3/source/includes/resources/app_features/_supported_features.md.erb
3:**Note**: SSH must also be [enabled globally](https://docs.cloudfoundry.org/running/config-ssh.html) and on the [space](#space-features).

docs/v3/source/includes/resources/space_features/_header.md
9:**Note**: SSH must also be [enabled globally](https://docs.cloudfoundry.org/running/config-ssh.html) and on the [app](#supported-app-features).

```

- There are few comments under the permissions table which sound like they are
  related to the REST endpoint implementation:

  - `Response will not show any space guids that a user would not otherwise be able to see (see [space view permissions](#get-a-space))`
  - `Space quotas in the response will not show any space guids that a user would not otherwise be able to see (see [space view permissions](#get-a-space)).`
  - `A user can always see themselves with this endpoint, regardless of role.`

    This sounds like the REST API should filter out resources the user is not
    permissioned to get (similarly to whatever `kubeclt can-i` does). In most
    of the cases the REST API should just perform the GET operation, this one
    sounds like an exception
