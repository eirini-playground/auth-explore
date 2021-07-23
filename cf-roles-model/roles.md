# Roles in CF

This document assumes a few things:
1. The minimum scope of the operations that a user can perform is the CF Space. We consider lower granularity such as application based to be out of scope
1. Spaces are implemented as namespaces.
1. Orgs *can* be programatically impelemented with simple Roles (i.e just giving multiple roles to a user that cover all Spaces in an Org), but we feel it could be better if an Org is a cluster and they Org roles are handled by ClusterRole

Resource|Action|Role|Notes|Can be done with RBAC|
--------|------|----|-----|---------------------|
Admin|Clear buildpack cache|Admin||
App Features|Get an app feature|Admin||
App Features|Get an app feature|Admin Read-Only||
App Features|Get an app feature|Global Auditor||
App Features|Get an app feature|Org Manager||
App Features|Get an app feature|Space Auditor||
App Features|Get an app feature|Space Developer||
App Features|Get an app feature|Space Manager||
App Features|Get an app feature|Space Supporter|Experimental|
App Features|List app features|Admin||
App Features|List app features|Admin Read-Only||
App Features|List app features|Global Auditor||
App Features|List app features|Org Manager||
App Features|List app features|Space Auditor||
App Features|List app features|Space Developer||
App Features|List app features|Space Manager||
App Features|List app features|Space Supporter|Experimental|
App Features|Update an app feature|Admin||
App Features|Update an app feature|Space Developer||
App Features|Update an app feature|Space Supporter|Experimental; Can only update **revisions** feature|
Apps|Create an app|Admin||
Apps|Create an app|Space Developer||
Apps|Set current droplet|Admin||
Apps|Set current droplet|Space Developer||
Apps|Set current droplet|Space Supporter|Experimental|
Apps|Delete an app|Admin||
Apps|Delete an app|Space Developer||
Apps|Get environment variables for an app|Admin||
Apps|Get environment variables for an app|Admin Read-Only||
Apps|Get environment variables for an app|Space Developer||
Apps|Get environment for an app|Admin||
Apps|Get environment for an app|Admin Read-Only||
Apps|Get environment for an app|Space Developer||
Apps|Get current droplet|Admin||
Apps|Get current droplet|Admin Read-Only||
Apps|Get current droplet|Global Auditor||
Apps|Get current droplet|Org Manager||
Apps|Get current droplet|Space Auditor||
Apps|Get current droplet|Space Developer||
Apps|Get current droplet|Space Manager||
Apps|Get current droplet|Space Supporter|Experimental|
Apps|Get current droplet association for an app|Admin||
Apps|Get current droplet association for an app|Admin Read-Only||
Apps|Get current droplet association for an app|Global Auditor||
Apps|Get current droplet association for an app|Org Manager||
Apps|Get current droplet association for an app|Space Auditor||
Apps|Get current droplet association for an app|Space Developer||
Apps|Get current droplet association for an app|Space Manager||
Apps|Get current droplet association for an app|Space Supporter|Experimental|
Apps|Get an app|Admin||
Apps|Get an app|Admin Read-Only||
Apps|Get an app|Global Auditor||
Apps|Get an app|Org Manager||
Apps|Get an app|Space Auditor||
Apps|Get an app|Space Developer||
Apps|Get an app|Space Manager||
Apps|Get an app|Space Supporter|Experimental|
Apps|List apps|All Roles||
Apps|Get permissions|Admin||
Apps|Get permissions|Admin Read-Only||
Apps|Get permissions|Global Auditor||
Apps|Get permissions|Org Manager||
Apps|Get permissions|Space Auditor||
Apps|Get permissions|Space Developer||
Apps|Get permissions|Space Manager||
Apps|Get permissions|Space Supporter|Experimental|
Apps|Restart an app|Admin||
Apps|Restart an app|Space Developer||
Apps|Restart an app|Space Supporter|Experimental|
Apps|Get SSH enabled for an app|Admin||
Apps|Get SSH enabled for an app|Admin Read-Only||
Apps|Get SSH enabled for an app|Global Auditor||
Apps|Get SSH enabled for an app|Org Manager||
Apps|Get SSH enabled for an app|Space Auditor||
Apps|Get SSH enabled for an app|Space Developer||
Apps|Get SSH enabled for an app|Space Manager||
Apps|Start an app|Admin||
Apps|Start an app|Space Developer||
Apps|Start an app|Space Supporter|Experimental|
Apps|Stop an app|Admin||
Apps|Stop an app|Space Developer||
Apps|Stop an app|Space Supporter|Experimental|
Apps|Update environment variables for an app|Admin||
Apps|Update environment variables for an app|Space Developer||
Apps|Update an app|Admin||
Apps|Update an app|Space Developer||
App Usage Events|Purge and seed app usage events|Admin||
App Usage Events|Get an app usage event|Admin||
App Usage Events|Get an app usage event|Admin Read-Only||
App Usage Events|Get an app usage event|Global Auditor||
App Usage Events|List app usage events|All Roles||
Audit Events|Get an audit event|Admin||
Audit Events|Get an audit event|Admin Read-Only||
Audit Events|Get an audit event|Global Auditor||
Audit Events|Get an audit event|Org Auditor|Cannot see events which occurred in orgs that the user does not belong to|
Audit Events|Get an audit event|Space Auditor|Cannot see events which occurred in spaces that the user does not belong to|
Audit Events|Get an audit event|Space Developer|Cannot see events which occurred in spaces that the user does not belong to|
Audit Events|Get an audit event|Space Supporter|Experimental; Cannot see events which occurred in spaces that the user does not belong to|
Audit Events|List audit events|Admin||
Audit Events|List audit events|Admin Read-Only||
Audit Events|List audit events|Global Auditor||
Audit Events|List audit events|Org Auditor||
Audit Events|List audit events|Org Manager||
Audit Events|List audit events|Space Auditor||
Audit Events|List audit events|Space Developer||
Audit Events|List audit events|Space Manager||
Audit Events|List audit events|Space Supporter|Experimental|
Buildpacks|Create a buildpack|Admin||
Buildpacks|Delete a buildpack|Admin||
Buildpacks|Get a buildpack|All Roles||
Buildpacks|List buildpacks|All Roles||
Buildpacks|Update a buildpack|Admin||
Buildpacks|Upload buildpack bits|Admin||
Builds|Create a build|Admin||
Builds|Create a build|Space Developer||
Builds|Create a build|Space Supporter|Experimental|
Builds|Get a build|Admin||
Builds|Get a build|Admin Read-Only||
Builds|Get a build|Global Auditor||
Builds|Get a build|Org Manager||
Builds|Get a build|Space Auditor||
Builds|Get a build|Space Developer||
Builds|Get a build|Space Manager||
Builds|Get a build|Space Supporter|Experimental|
Builds|List builds for an app|Admin||
Builds|List builds for an app|Admin Read-Only||
Builds|List builds for an app|Global Auditor||
Builds|List builds for an app|Org Manager||
Builds|List builds for an app|Space Auditor||
Builds|List builds for an app|Space Developer||
Builds|List builds for an app|Space Manager||
Builds|List builds for an app|Space Supporter|Experimental|
Builds|List builds|All Roles||
Builds|Update a build|Admin||
Builds|Update a build|Space Developer||
Builds|Update a build|Build State Updater|This is a special component role; [read more about component roles](#component-roles)|
Deployments|Cancel a deployment|Admin||
Deployments|Cancel a deployment|Space Developer||
Deployments|Cancel a deployment|Space Supporter|Experimental|
Deployments|Create a deployment|Admin||
Deployments|Create a deployment|Space Developer||
Deployments|Create a deployment|Space Supporter|Experimental|
Deployments|Get a deployment|Admin||
Deployments|Get a deployment|Admin Read-Only||
Deployments|Get a deployment|Global Auditor||
Deployments|Get a deployment|Org Manager||
Deployments|Get a deployment|Space Auditor||
Deployments|Get a deployment|Space Developer||
Deployments|Get a deployment|Space Manager||
Deployments|Get a deployment|Space Supporter|Experimental|
Deployments|List deployments|All Roles||
Deployments|Update a deployment|Admin||
Deployments|Update a deployment|Space Developer||
Domains|Create a domain|Admin||
Domains|Create a domain|Org Manager|When an `organization` relationship is provided|
Domains|Delete a domain|Admin||
Domains|Delete a domain|Org Manager|If domain is scoped to organization managed by the org manager|
Domains|Get a domain|Admin||
Domains|Get a domain|Admin Read-Only||
Domains|Get a domain|Global Auditor||
Domains|Get a domain|Org Auditor||
Domains|Get a domain|Org Billing Manager|Can only view domains without an organization relationship|
Domains|Get a domain|Org Manager||
Domains|Get a domain|Space Auditor||
Domains|Get a domain|Space Developer||
Domains|Get a domain|Space Manager||
Domains|Get a domain|Space Supporter|Experimental|
Domains|List domains for an organization|All Roles||
Domains|List domains|All Roles||
Domains|Share a domain|Admin||
Domains|Share a domain|Org Manager||
Domains|Unshare a domain|Admin||
Domains|Unshare a domain|Org Manager|_Can be in either the domain's owning organization or the organization it has been shared to_|
Domains|Update a domain|Admin||
Domains|Update a domain|Org Manager|If domain is scoped to organization managed by the org manager|
Droplets|Copy a droplet|Admin||
Droplets|Copy a droplet|Space Developer||
Droplets|Create a droplet|Admin||
Droplets|Create a droplet|Space Developer||
Droplets|Delete a droplet|Admin||
Droplets|Delete a droplet|Space Developer||
Droplets|Download droplet bits|Admin||
Droplets|Download droplet bits|Admin Read-Only||
Droplets|Download droplet bits|Global Auditor||
Droplets|Download droplet bits|Org Manager||
Droplets|Download droplet bits|Space Auditor||
Droplets|Download droplet bits|Space Developer||
Droplets|Download droplet bits|Space Manager||
Droplets|Get a droplet|Admin||
Droplets|Get a droplet|Admin Read-Only||
Droplets|Get a droplet|Global Auditor|Some fields are redacted|
Droplets|Get a droplet|Org Manager|Some fields are redacted|
Droplets|Get a droplet|Space Auditor|Some fields are redacted|
Droplets|Get a droplet|Space Developer||
Droplets|Get a droplet|Space Manager|Some fields are redacted|
Droplets|Get a droplet|Space Supporter|Experimental; Some fields are redacted|
Droplets|List droplets for an app|Admin||
Droplets|List droplets for an app|Admin Read-Only||
Droplets|List droplets for an app|Global Auditor||
Droplets|List droplets for an app|Org Manager||
Droplets|List droplets for an app|Space Auditor||
Droplets|List droplets for an app|Space Developer||
Droplets|List droplets for an app|Space Manager||
Droplets|List droplets for an app|Space Supporter|Experimental|
Droplets|List droplets for a package|Admin||
Droplets|List droplets for a package|Admin Read-Only||
Droplets|List droplets for a package|Global Auditor||
Droplets|List droplets for a package|Org Manager||
Droplets|List droplets for a package|Space Auditor||
Droplets|List droplets for a package|Space Developer||
Droplets|List droplets for a package|Space Manager||
Droplets|List droplets for a package|Space Supporter|Experimental|
Droplets|List droplets|All Roles||
Droplets|Update a droplet|Admin||
Droplets|Update a droplet|Space Developer||
Droplets|Upload droplet bits|Admin||
Droplets|Upload droplet bits|Space Developer||
Environment Variable Groups|Get an environment variable group|All Roles||
Environment Variable Groups|Update environment variable group|Admin||
Feature Flags|Get a feature flag|All Roles||
Feature Flags|List feature flags|All Roles||
Feature Flags|Update a feature flag|Admin||
Info|Get platform usage summary|Admin||
Info|Get platform usage summary|Admin Read-Only||
Info|Get platform usage summary|Global Auditor||
Isolation Segments|Entitle organizations for an isolation segment|Admin||
Isolation Segments|Create an isolation segment|Admin||
Isolation Segments|Delete an isolation segment|Admin||
Isolation Segments|Get an isolation segment|All Roles||
Isolation Segments|List isolation segments|All Roles||
Isolation Segments|List organizations relationship|All Roles||
Isolation Segments|List spaces relationship|All Roles||
Isolation Segments|Revoke entitlement to isolation segment for an organization|Admin||
Isolation Segments|Update an isolation segment|Admin||
Jobs|Get a job|All Roles||
Manifests|Apply a manifest to a space|Admin||
Manifests|Apply a manifest to a space|Space Developer||
Manifests|Create a manifest diff for a space (experimental)|Admin||
Manifests|Create a manifest diff for a space (experimental)|Space Developer||
Manifests|Generate a manifest for an app|Admin||
Manifests|Generate a manifest for an app|Admin Read-Only||
Manifests|Generate a manifest for an app|Space Developer||
Organization Quotas|Apply an organization quota to an organization|Admin||
Organization Quotas|Create an organization quota|Admin||
Organization Quotas|Delete an organization quota|Admin||
Organization Quotas|Get an organization quota|Admin||
Organization Quotas|Get an organization quota|Admin Read-Only||
Organization Quotas|Get an organization quota|Global Auditor||
Organization Quotas|Get an organization quota|Org Manager|Response will only include guids of managed organizations|
Organization Quotas|Get an organization quota|Org Auditor|Response will only include guids of audited organizations|
Organization Quotas|Get an organization quota|Org Billing Manager|Response will only include guids of billing-managed organizations|
Organization Quotas|Get an organization quota|Space Auditor|Response will only include guids of parent organizations|
Organization Quotas|Get an organization quota|Space Developer|Response will only include guids of parent organizations|
Organization Quotas|Get an organization quota|Space Manager|Response will only include guids of parent organizations|
Organization Quotas|Get an organization quota|Space Supporter|Experimental / Response will only include guids of parent organizations|
Organization Quotas|List organization quotas|Admin||
Organization Quotas|List organization quotas|Admin Read-Only||
Organization Quotas|List organization quotas|Global Auditor||
Organization Quotas|List organization quotas|Org Manager|Response will only include guids of managed organizations|
Organization Quotas|List organization quotas|Org Auditor|Response will only include guids of audited organizations|
Organization Quotas|List organization quotas|Org Billing Manager|Response will only include guids of billing-managed organizations|
Organization Quotas|List organization quotas|Space Auditor|Response will only include guids of parent organizations|
Organization Quotas|List organization quotas|Space Developer|Response will only include guids of parent organizations|
Organization Quotas|List organization quotas|Space Manager|Response will only include guids of parent organizations|
Organization Quotas|List organization quotas|Space Supporter|Experimental / Response will only include guids of parent organizations|
Organization Quotas|Update an organization quota|Admin||
Organizations|Assign default isolation segment|Admin||
Organizations|Assign default isolation segment|Org Manager||
Organizations|Create an organization|Admin||
Organizations|Delete an organization|Admin||
Organizations|Get an organization|All Roles||
Organizations|Get default domain|Admin||
Organizations|Get default domain|Admin Read-Only||
Organizations|Get default domain|Global Auditor||
Organizations|Get default domain|Org Auditor||
Organizations|Get default domain|Org Billing Manager|Can only view domains without an organization relationship|
Organizations|Get default domain|Org Manager||
Organizations|Get default domain|Space Auditor||
Organizations|Get default domain|Space Developer||
Organizations|Get default domain|Space Manager||
Organizations|Get default domain|Space Supporter|Experimental|
Organizations|Get default isolation segment|All Roles||
Organizations|Get usage summary|All Roles||
Organizations|List organizations for isolation segment|Admin||
Organizations|List organizations for isolation segment|Admin Read-Only||
Organizations|List organizations for isolation segment|Global Auditor||
Organizations|List organizations for isolation segment|Org Auditor||
Organizations|List organizations for isolation segment|Org Billing Manager||
Organizations|List organizations for isolation segment|Org Manager||
Organizations|List organizations|All Roles||
Organizations|Update an organization|Admin||
Organizations|Update an organization|Org Manager||
Packages|Copy a package|Admin||
Packages|Copy a package|Space Developer||
Packages|Create a package|Admin||
Packages|Create a package|Space Developer||
Packages|Delete a package|Admin||
Packages|Delete a package|Space Developer||
Packages|Download package bits|Admin||
Packages|Download package bits|Space Developer||
Packages|Get a package|Admin||
Packages|Get a package|Admin Read-Only||
Packages|Get a package|Global Auditor||
Packages|Get a package|Org Manager||
Packages|Get a package|Space Auditor||
Packages|Get a package|Space Developer||
Packages|Get a package|Space Manager||
Packages|Get a package|Space Supporter|Experimental|
Packages|List packages for an app|Admin||
Packages|List packages for an app|Admin Read-Only||
Packages|List packages for an app|Global Auditor||
Packages|List packages for an app|Org Manager||
Packages|List packages for an app|Space Auditor||
Packages|List packages for an app|Space Developer||
Packages|List packages for an app|Space Manager||
Packages|List packages for an app|Space Supporter|Experimental|
Packages|List packages|All Roles||
Packages|Update a package|Admin||
Packages|Update a package|Space Developer||
Packages|Upload package bits|Admin||
Packages|Upload package bits|Space Developer||
Processes|Get a process|Admin||
Processes|Get a process|Admin Read-Only||
Processes|Get a process|Global Auditor|Some fields are redacted|
Processes|Get a process|Org Manager|Some fields are redacted|
Processes|Get a process|Space Auditor|Some fields are redacted|
Processes|Get a process|Space Developer||
Processes|Get a process|Space Manager|Some fields are redacted|
Processes|Get a process|Space Supporter|Experimental; Some fields are redacted|
Processes|List processes for app|Admin||
Processes|List processes for app|Admin Read-Only||
Processes|List processes for app|Global Auditor||
Processes|List processes for app|Org Manager||
Processes|List processes for app|Space Auditor||
Processes|List processes for app|Space Developer||
Processes|List processes for app|Space Manager||
Processes|List processes for app|Space Supporter||
Processes|List processes|All Roles||
Processes|Scale a process|Admin||
Processes|Scale a process|Space Developer||
Processes|Scale a process|Space Supporter||
Processes|Get stats for a process|Admin||
Processes|Get stats for a process|Admin Read-Only||
Processes|Get stats for a process|Global Auditor|Some fields are redacted|
Processes|Get stats for a process|Org Manager|Some fields are redacted|
Processes|Get stats for a process|Space Auditor|Some fields are redacted|
Processes|Get stats for a process|Space Developer||
Processes|Get stats for a process|Space Manager|Some fields are redacted|
Processes|Get stats for a process|Space Supporter|Experimental; Some fields are redacted|
Processes|Terminate a process instance|Admin||
Processes|Terminate a process instance|Space Developer||
Processes|Terminate a process instance|Space Supporter||
Processes|Update a process|Admin||
Processes|Update a process|Space Developer||
Processes|Update a process|Space Supporter||
Resource Matches|Create a resource match|All Roles||
Roles|Create a role|Admin||
Roles|Create a role|Org Manager|Can create roles in managed organizations and spaces within those organizations; can also create roles for users outside of managed organizations when `set_roles_by_username` [feature_flag](#list-of-feature-flags) is enabled; this requires identifying users by username and origin|
Roles|Create a role|Space Manager|Can create roles in managed spaces for users in their org|
Roles|Delete a role|Admin||
Roles|Delete a role|Org Manager|Can delete roles in managed organizations or spaces in those organizations|
Roles|Delete a role|Space Manager|Can delete roles in managed spaces|
Roles|Get a role|Admin||
Roles|Get a role|Admin Read-Only||
Roles|Get a role|Global Auditor||
Roles|Get a role|Org Manager|Can see roles in managed organizations or spaces in those organizations|
Roles|Get a role|Org Auditor|Can only see organization roles in audited organizations|
Roles|Get a role|Org Billing Manager|Can only see organization roles in billing-managed organizations|
Roles|Get a role|Space Auditor|Can see roles in audited spaces or parent organizations|
Roles|Get a role|Space Developer|Can see roles in developed spaces or parent organizations|
Roles|Get a role|Space Manager|Can see roles in managed spaces or parent organizations|
Roles|Get a role|[Space Supporter](#valid-role-types) (*under development*)|Can see roles in supported spaces or parent organizations|
Roles|List roles|All Roles||
Routes|Check reserved routes for a domain|Admin||
Routes|Check reserved routes for a domain|Admin Read-Only||
Routes|Check reserved routes for a domain|Global Auditor||
Routes|Check reserved routes for a domain|Org Auditor||
Routes|Check reserved routes for a domain|Org Billing Manager|Can only check if routes exist for a domain without an organization relationship|
Routes|Check reserved routes for a domain|Org Manager||
Routes|Check reserved routes for a domain|Space Auditor||
Routes|Check reserved routes for a domain|Space Developer||
Routes|Check reserved routes for a domain|Space Manager||
Routes|Check reserved routes for a domain|Space Supporter|Experimental|
Routes|Create a route|Admin||
Routes|Create a route|Space Developer||
Routes|Create a route|Space Supporter|Experimental|
Routes|Delete a route|Admin||
Routes|Delete a route|Space Developer||
Routes|Delete a route|Space Supporter|Experimental|
Routes|Delete unmapped routes for a space|Admin||
Routes|Delete unmapped routes for a space|Space Developer||
Routes|Delete unmapped routes for a space|Space Supporter|Experimental|
Routes|Get a route|Admin||
Routes|Get a route|Admin Read-Only||
Routes|Get a route|Global Auditor||
Routes|Get a route|Org Auditor||
Routes|Get a route|Org Manager||
Routes|Get a route|Space Auditor||
Routes|Get a route|Space Developer||
Routes|Get a route|Space Manager||
Routes|Get a route|Space Supporter|Experimental|
Routes|Insert destinations for a route|Admin||
Routes|Insert destinations for a route|Space Developer||
Routes|Insert destinations for a route|Space Supporter|Experimental|
Routes|List destinations for a route|Admin||
Routes|List destinations for a route|Admin Read-Only||
Routes|List destinations for a route|Global Auditor||
Routes|List destinations for a route|Org Auditor||
Routes|List destinations for a route|Org Manager||
Routes|List destinations for a route|Space Auditor||
Routes|List destinations for a route|Space Developer||
Routes|List destinations for a route|Space Manager||
Routes|List destinations for a route|Space Supporter|Experimental|
Routes|List routes for an app|Admin||
Routes|List routes for an app|Admin Read-Only||
Routes|List routes for an app|Global Auditor||
Routes|List routes for an app|Org Manager||
Routes|List routes for an app|Space Auditor||
Routes|List routes for an app|Space Developer||
Routes|List routes for an app|Space Manager||
Routes|List routes for an app|Space Supporter|Experimental|
Routes|List routes|All Roles||
Routes|Remove destination for a route|Admin||
Routes|Remove destination for a route|Space Developer||
Routes|Remove destination for a route|Space Supporter|Experimental|
Routes|Replace all destinations for a route|Admin||
Routes|Replace all destinations for a route|Space Developer||
Routes|Replace all destinations for a route|Space Supporter|Experimental|
Routes|Update a route|Admin||
Routes|Update a route|Space Developer||
Routes|Update a route|Space Supporter|Experimental|
Security Groups|Bind a running security group to spaces|Admin||
Security Groups|Bind a running security group to spaces|Space Manager|Can bind visible security groups to their spaces (visible groups are globally–enabled security groups or groups associated with a space they can see)|
Security Groups|Bind a running security group to spaces|Org Manager|Can bind visible security groups to their organizations' spaces (visible groups are globally–enabled security groups or groups associated with a space they can see)|
Security Groups|Bind a staging security group to spaces|Admin||
Security Groups|Bind a staging security group to spaces|Space Manager|Can bind visible security groups to their spaces (visible groups are globally–enabled security groups or groups associated with a space they can see)|
Security Groups|Bind a staging security group to spaces|Org Manager|Can bind visible security groups to their organizations' spaces (visible groups are globally–enabled security groups or groups associated with a space they can see)|
Security Groups|Create a security group|Admin||
Security Groups|Delete a security group|Admin||
Security Groups|Get a security group|Admin|Can see all security groups|
Security Groups|Get a security group|Admin Read-Only|Can see all security groups|
Security Groups|Get a security group|Global Auditor|Can see all security groups|
Security Groups|Get a security group|Org Auditor|Can see globally enabled security groups|
Security Groups|Get a security group|Org Billing Manager|Can see globally enabled security groups|
Security Groups|Get a security group|Org Manager|Can see globally enabled security groups or groups associated with a space they can see|
Security Groups|Get a security group|Space Auditor|Can see globally enabled security groups or groups associated with a space they can see|
Security Groups|Get a security group|Space Developer|Can see globally enabled security groups or groups associated with a space they can see|
Security Groups|Get a security group|Space Manager|Can see globally enabled security groups or groups associated with a space they can see|
Security Groups|Get a security group|Space Supporter|Experimental. Can see globally enabled security groups or groups associated with a space they can see|
Security Groups|List security groups|Admin|Can see all security groups|
Security Groups|List security groups|Admin Read-Only|Can see all security groups|
Security Groups|List security groups|Global Auditor|Can see all security groups|
Security Groups|List security groups|Org Auditor|Can see globally–enabled security groups|
Security Groups|List security groups|Org Billing Manager|Can see globally–enabled security groups|
Security Groups|List security groups|Org Manager|Can see globally–enabled security groups or groups associated with a space they can see|
Security Groups|List security groups|Space Auditor|Can see globally–enabled security groups or groups associated with a space they can see|
Security Groups|List security groups|Space Developer|Can see globally–enabled security groups or groups associated with a space they can see|
Security Groups|List security groups|Space Manager|Can see globally–enabled security groups or groups associated with a space they can see|
Security Groups|List security groups|Space Supporter|Experimental. Can see globally–enabled security groups or groups associated with a space they can see|
Security Groups|List running security groups for a space|Admin|Can see all security groups|
Security Groups|List running security groups for a space|Admin Read-Only|Can see all security groups|
Security Groups|List running security groups for a space|Global Auditor|Can see all security groups|
Security Groups|List running security groups for a space|Org Manager|Can see globally-enabled security groups and groups associated with spaces in their managed organizations|
Security Groups|List running security groups for a space|Space Auditor|Can see globally-enabled security groups and groups associated with spaces where they have this role|
Security Groups|List running security groups for a space|Space Developer|Can see globally-enabled security groups and groups associated with spaces where they have this role|
Security Groups|List running security groups for a space|Space Manager|Can see globally-enabled security groups and groups associated with spaces where they have this role|
Security Groups|List running security groups for a space|Space Supporter|Experimental. Can see globally-enabled security groups and groups associated with spaces where they have this role|
Security Groups|List staging security groups for a space|Admin|Can see all security groups|
Security Groups|List staging security groups for a space|Admin Read-Only|Can see all security groups|
Security Groups|List staging security groups for a space|Global Auditor|Can see all security groups|
Security Groups|List staging security groups for a space|Org Manager|Can see globally-enabled security groups and groups associated with spaces in their managed organizations|
Security Groups|List staging security groups for a space|Space Auditor|Can see globally-enabled security groups and groups associated with spaces where they have this role|
Security Groups|List staging security groups for a space|Space Developer|Can see globally-enabled security groups and groups associated with spaces where they have this role|
Security Groups|List staging security groups for a space|Space Manager|Can see globally-enabled security groups and groups associated with spaces where they have this role|
Security Groups|List staging security groups for a space|Space Supporter|Experimental. Can see globally-enabled security groups and groups associated with spaces where they have this role|
Security Groups|Unbind a running security group from a space|Admin||
Security Groups|Unbind a running security group from a space|Space Manager|Can unbind visible security groups from their spaces (visible groups are globally–enabled security groups or groups associated with a space they can see)|
Security Groups|Unbind a running security group from a space|Org Manager|Can unbind visible security groups from their organizations' spaces (visible groups are globally–enabled security groups or groups associated with a space they can see)|
Security Groups|Unbind a staging security group from a space|Admin||
Security Groups|Unbind a staging security group from a space|Space Manager|Can unbind visible security groups from their spaces (visible groups are globally–enabled security groups or groups associated with a space they can see)|
Security Groups|Unbind a staging security group from a space|Org Manager|Can unbind visible security groups from their organizations' spaces (visible groups are globally–enabled security groups or groups associated with a space they can see)|
Security Groups|Update a security group|Admin||
Service Brokers|Create a service broker|Admin||
Service Brokers|Create a service broker|Space Developer||
Service Brokers|Delete a service broker|Admin||
Service Brokers|Delete a service broker|Space Developer|Only space-scoped brokers|
Service Brokers|Get a service broker|Admin||
Service Brokers|Get a service broker|Admin Read-Only||
Service Brokers|Get a service broker|Global Auditor||
Service Brokers|Get a service broker|Space Developer|Only space-scoped brokers|
Service Brokers|Get a service broker|Space Supporter|Experimental; Only space-scoped brokers|
Service Brokers|List service brokers|Admin||
Service Brokers|List service brokers|Admin Read-Only||
Service Brokers|List service brokers|Global Auditor||
Service Brokers|List service brokers|Space Developer|Only space-scoped brokers|
Service Brokers|List service brokers|Space Supporter|Experimental; Only space-scoped brokers|
Service Brokers|List service brokers|Other|Will receive an empty list|
Service Brokers|Update a service broker|Admin||
Service Brokers|Update a service broker|Space Developer|Only space-scoped brokers|
Service Credential Binding|Create a service credential binding|Admin||
Service Credential Binding|Create a service credential binding|Space Developer||
Service Credential Binding|Delete a service credential binding|Admin||
Service Credential Binding|Delete a service credential binding|Space Developer||
Service Credential Binding|Get a service credential binding details|Admin||
Service Credential Binding|Get a service credential binding details|Admin Read-Only||
Service Credential Binding|Get a service credential binding details|Space Developer||
Service Credential Binding|Get a service credential binding|Admin||
Service Credential Binding|Get a service credential binding|Admin Read-Only||
Service Credential Binding|Get a service credential binding|Global Auditor||
Service Credential Binding|Get a service credential binding|Org Manager||
Service Credential Binding|Get a service credential binding|Space Auditor||
Service Credential Binding|Get a service credential binding|Space Developer||
Service Credential Binding|Get a service credential binding|Space Manager||
Service Credential Binding|List service credential bindings|Admin||
Service Credential Binding|List service credential bindings|Admin Read-Only||
Service Credential Binding|List service credential bindings|Global Auditor||
Service Credential Binding|List service credential bindings|Org Manager||
Service Credential Binding|List service credential bindings|Space Auditor||
Service Credential Binding|List service credential bindings|Space Developer||
Service Credential Binding|List service credential bindings|Space Manager||
Service Credential Binding|Get parameters for a service credential binding|Admin||
Service Credential Binding|Get parameters for a service credential binding|Admin Read-Only||
Service Credential Binding|Get parameters for a service credential binding|Space Developer||
Service Credential Binding|Update a service credential binding|Admin||
Service Credential Binding|Update a service credential binding|Space Developer||
Service Instances|Create a service instance|Admin||
Service Instances|Create a service instance|Space Developer||
Service Instances|Get credentials for a user-provided service instance|Admin||
Service Instances|Get credentials for a user-provided service instance|Admin Read-Only||
Service Instances|Get credentials for a user-provided service instance|Space Developer||
Service Instances|Get credentials for a user-provided service instance|Space Manager||
Service Instances|Delete a service instance|Admin||
Service Instances|Delete a service instance|Space Developer||
Service Instances|Get a service instance|Admin||
Service Instances|Get a service instance|Admin Read-Only||
Service Instances|Get a service instance|Global Auditor||
Service Instances|Get a service instance|Org Manager||
Service Instances|Get a service instance|Space Auditor||
Service Instances|Get a service instance|Space Developer||
Service Instances|Get a service instance|Space Manager||
Service Instances|Get usage summary in shared spaces|Admin||
Service Instances|Get usage summary in shared spaces|Admin Read-Only||
Service Instances|Get usage summary in shared spaces|Global Auditor||
Service Instances|Get usage summary in shared spaces|Org Manager||
Service Instances|Get usage summary in shared spaces|Space Auditor||
Service Instances|Get usage summary in shared spaces|Space Developer||
Service Instances|Get usage summary in shared spaces|Space Manager||
Service Instances|List service instances|All Roles||
Service Instances|List shared spaces relationship|Admin||
Service Instances|List shared spaces relationship|Admin Read-Only||
Service Instances|List shared spaces relationship|Global Auditor||
Service Instances|List shared spaces relationship|Org Manager||
Service Instances|List shared spaces relationship|Space Auditor||
Service Instances|List shared spaces relationship|Space Developer||
Service Instances|List shared spaces relationship|Space Manager||
Service Instances|Get parameters for a managed service instance|Admin||
Service Instances|Get parameters for a managed service instance|Admin Read-Only||
Service Instances|Get parameters for a managed service instance|Global Auditor||
Service Instances|Get parameters for a managed service instance|Org Manager||
Service Instances|Get parameters for a managed service instance|Space Auditor||
Service Instances|Get parameters for a managed service instance|Space Developer||
Service Instances|Get parameters for a managed service instance|Space Manager||
Service Instances|Share a service instance to other spaces|Admin||
Service Instances|Share a service instance to other spaces|Space Developer||
Service Instances|Unshare a service instance from another space|Admin||
Service Instances|Unshare a service instance from another space|Space Developer||
Service Instances|Update a service instance|Admin||
Service Instances|Update a service instance|Space Developer||
Service Offerings|Delete a service offering|Admin||
Service Offerings|Delete a service offering|Space Developer|Only service offerings from space-scoped brokers|
Service Offerings|Get a service offering|All Roles||
Service Offerings|Get a service offering|Unauthenticated Users (for service offerings with public plans, unless `hide_marketplace_from_unauthenticated_users` is set)||
Service Offerings|List service offerings|All Roles||
Service Offerings|List service offerings|Unauthenticated Users (for service offerings with public plans, unless `hide_marketplace_from_unauthenticated_users` is set)||
Service Offerings|Update a service offering|Admin||
Service Offerings|Update a service offering|Space Developer|Only for service offerings from space-scoped brokers|
Service Plans|Delete a service plan|Admin||
Service Plans|Delete a service plan|Space Developer|Only service plans from space-scoped brokers|
Service Plans|Get a service plan|All Roles||
Service Plans|Get a service plan|Unauthenticated Users (for public plans, unless `hide_marketplace_from_unauthenticated_users` is set)||
Service Plans|List service plans|All Roles||
Service Plans|List service plans|Unauthenticated Users (for public plans, unless `hide_marketplace_from_unauthenticated_users` is set)||
Service Plans|Update a service plan|Admin||
Service Plans|Update a service plan|Space Developer|Only for service plans from space-scoped brokers|
Service Plan Visibility|Apply a service plan visibility|Admin||
Service Plan Visibility|Remove organization from a service plan visibility|Admin||
Service Plan Visibility|Get a service plan visibility|All Roles||
Service Plan Visibility|Update a service plan visibility|Admin||
Service Route Binding|Create a service route binding|Admin||
Service Route Binding|Create a service route binding|Space Developer||
Service Route Binding|Create a service route binding|Space Supporter|Experimental|
Service Route Binding|Delete a service route binding|Admin||
Service Route Binding|Delete a service route binding|Space Developer||
Service Route Binding|Delete a service route binding|Space Supporter|Experimental|
Service Route Binding|Get a service route binding|Admin||
Service Route Binding|Get a service route binding|Admin Read-Only||
Service Route Binding|Get a service route binding|Global Auditor||
Service Route Binding|Get a service route binding|Org Manager||
Service Route Binding|Get a service route binding|Space Auditor||
Service Route Binding|Get a service route binding|Space Developer||
Service Route Binding|Get a service route binding|Space Manager||
Service Route Binding|Get a service route binding|Space Supporter|Experimental|
Service Route Binding|List service route bindings|Admin||
Service Route Binding|List service route bindings|Admin Read-Only||
Service Route Binding|List service route bindings|Global Auditor||
Service Route Binding|List service route bindings|Org Manager||
Service Route Binding|List service route bindings|Space Auditor||
Service Route Binding|List service route bindings|Space Developer||
Service Route Binding|List service route bindings|Space Manager||
Service Route Binding|Get parameters for a route binding|Admin||
Service Route Binding|Get parameters for a route binding|Admin Read-Only||
Service Route Binding|Get parameters for a route binding|Space Developer||
Service Route Binding|Update a service route binding|Admin||
Service Route Binding|Update a service route binding|Space Developer||
Service Usage Events|Purge and seed service usage events|Admin||
Service Usage Events|Get a service usage event|Admin||
Service Usage Events|Get a service usage event|Admin Read-Only||
Service Usage Events|Get a service usage event|Global Auditor||
Service Usage Events|List service usage events|All Roles||
Space Features|Get a space feature|Admin||
Space Features|Get a space feature|Admin Read-Only||
Space Features|Get a space feature|Global Auditor||
Space Features|Get a space feature|Org Manager||
Space Features|Get a space feature|Space Auditor||
Space Features|Get a space feature|Space Developer||
Space Features|Get a space feature|Space Manager||
Space Features|Get a space feature|Space Supporter|Experimental|
Space Features|List space features|Admin||
Space Features|List space features|Admin Read-Only||
Space Features|List space features|Global Auditor||
Space Features|List space features|Org Manager||
Space Features|List space features|Space Auditor||
Space Features|List space features|Space Developer||
Space Features|List space features|Space Manager||
Space Features|List space features|Space Supporter|Experimental|
Space Features|Update space features|Admin||
Space Features|Update space features|Org Manager||
Space Features|Update space features|Space Manager||
Space Quotas|Apply a space quota to a space|Admin||
Space Quotas|Apply a space quota to a space|Org Manager|Can apply space quotas to spaces within their managed organizations|
Space Quotas|Create a space quota|Admin||
Space Quotas|Create a space quota|Org Manager|Org managers can create space quotas in their managed organizations|
Space Quotas|Delete a space quota|Admin||
Space Quotas|Delete a space quota|Org Manager|Can delete space quotas within their managed organizations|
Space Quotas|Get a space quota|Admin||
Space Quotas|Get a space quota|Admin Read-Only||
Space Quotas|Get a space quota|Global Auditor||
Space Quotas|Get a space quota|Org Manager|Can only query space quotas owned by affiliated organizations|
Space Quotas|Get a space quota|Space Auditor|Can only query space quotas applied to affiliated spaces|
Space Quotas|Get a space quota|Space Developer|Can only query space quotas applied to affiliated spaces|
Space Quotas|Get a space quota|Space Manager|Can only query space quotas applied to affiliated spaces|
Space Quotas|Get a space quota|Space Supporter|Can only query space quotas applied to affiliated spaces|
Space Quotas|List space quotas|All Roles||
Space Quotas|Remove a space quota from a space|Admin||
Space Quotas|Remove a space quota from a space|Org Manager|Can remove space quotas from spaces within their managed organizations|
Space Quotas|Update a space quota|Admin||
Space Quotas|Update a space quota|Org Manager|Can update space quotas in the organization where they have this role|
Spaces|Create a space|Admin||
Spaces|Create a space|Org Manager||
Spaces|Delete a space|Admin||
Spaces|Delete a space|Org Manager||
Spaces|Get a space|Admin||
Spaces|Get a space|Admin Read-Only||
Spaces|Get a space|Global Auditor||
Spaces|Get a space|Org Manager||
Spaces|Get a space|Space Auditor||
Spaces|Get a space|Space Developer||
Spaces|Get a space|Space Manager||
Spaces|Get a space|Space Supporter|Experimental|
Spaces|Get assigned isolation segment|Admin||
Spaces|Get assigned isolation segment|Admin Read-Only||
Spaces|Get assigned isolation segment|Global Auditor||
Spaces|Get assigned isolation segment|Org Manager||
Spaces|Get assigned isolation segment|Space Auditor||
Spaces|Get assigned isolation segment|Space Developer||
Spaces|Get assigned isolation segment|Space Manager||
Spaces|Get assigned isolation segment|Space Supporter|Experimental|
Spaces|List spaces|All Roles||
Spaces|Manage isolation segment|Admin||
Spaces|Manage isolation segment|Org Manager||
Spaces|Update a space|Admin||
Spaces|Update a space|Org Manager||
Spaces|Update a space|Space Manager||
Stacks|Create a stack|Admin||
Stacks|Delete a stack|Admin||
Stacks|Get a stack|All Roles||
Stacks|List stacks|All Roles||
Stacks|Update a stack|Admin||
Stacks|Update a stack|Space Developer||
Tasks|Cancel a task|Admin||
Tasks|Cancel a task|Space Developer||
Tasks|Cancel a task|Space Supporter|Experimental|
Tasks|Create a task|Admin||
Tasks|Create a task|Space Developer||
Tasks|Get a task|Admin||
Tasks|Get a task|Admin Read-Only||
Tasks|Get a task|Global Auditor|`command` field redacted|
Tasks|Get a task|Org Manager|`command` field redacted|
Tasks|Get a task|Space Auditor|`command` field redacted|
Tasks|Get a task|Space Developer||
Tasks|Get a task|Space Manager|`command` field redacted|
Tasks|Get a task|Space Supporter|Experimental, `command` field redacted|
Tasks|List tasks for an app|Admin||
Tasks|List tasks for an app|Admin Read-Only||
Tasks|List tasks for an app|Global Auditor|`command` field redacted|
Tasks|List tasks for an app|Org Manager|`command` field redacted|
Tasks|List tasks for an app|Space Auditor|`command` field redacted|
Tasks|List tasks for an app|Space Developer||
Tasks|List tasks for an app|Space Manager|`command` field redacted|
Tasks|List tasks for an app|Space Supporter|Experimental, `command` field redacted|
Tasks|List tasks|All Roles||
Tasks|Update a task|Admin||
Tasks|Update a task|Space Developer||
Users|Create a user|Admin||
Users|Delete a user|Admin||
Users|Get a user|Admin||
Users|Get a user|Admin Read-Only||
Users|Get a user|Global Auditor||
Users|Get a user|Org Auditor|Can only view users affiliated with their org|
Users|Get a user|Org Billing Manager|Can only view users affiliated with their org|
Users|Get a user|Org Manager|Can only view users affiliated with their org|
Users|Get a user|Space Auditor|Can only view users affiliated with their org|
Users|Get a user|Space Developer|Can only view users affiliated with their org|
Users|Get a user|Space Manager|Can only view users affiliated with their org|
Users|Get a user|Space Supporter|Experimental; Can only view users affiliated with their org|
Users|List users|Admin||
Users|List users|Admin Read-Only||
Users|List users|Global Auditor||
Users|List users|Org Auditor|Can only view users affiliated with their org|
Users|List users|Org Billing Manager|Can only view users affiliated with their org|
Users|List users|Org Manager|Can only view users affiliated with their org|
Users|List users|Space Auditor|Can only view users affiliated with their org|
Users|List users|Space Developer|Can only view users affiliated with their org|
Users|List users|Space Manager|Can only view users affiliated with their org|
Users|List users|Space Supporter|Experimental; Can only view users affiliated with their org|
Users|Update a user|Admin||
