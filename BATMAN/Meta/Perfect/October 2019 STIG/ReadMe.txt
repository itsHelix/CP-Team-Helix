WARNING
-------

It must be noted that the Group Policy Objects (GPO) provided should be evaluated in a local, representative test environment before implementation within production environments. The extensive variety of environments makes it impossible to test these GPOs for all potential enterprise Active Directory and software configurations. For most environments, failure to test before implementation may lead to a loss of required functionality.

It is especially important to fully test with all GPOs against all Windows Operating Systems, internet browsers, specific and legacy applications which are targeted by each STIG GPO which are currently used in the environment.


INTRODUCTION
------------

This package contains ADMX template files, GPO backups exports, GPO reports, and WMI filter exports. It is to provide enterprise administrators the supporting GPOs and related files to aid them in the deployment of GPOs within their enterprise to meet STIG settings. Administrators are expected to fully test GPOs in test environments prior to live production deployments.


MAINTENANCE
-----------

This package will be updated with each quarterly release of STIG updates. If a targeted STIG within package is released out of cycle, the package will be updated accordingly. Additional if a new STIG is targeted to provide a supporting GPO, the package will be updated to include GPO backup, GPO report, and checklist file and ADMX and WMI filter exports as required.

With declaration of sundown of Windows 7 and Windows 8.1 STIGs in April 2018, the Windows 7 and Windows 8.1 GPOs and supporting files will no longer be updated. The April 2018 GPOs and supporting files will remain part of baseline package and will not be updated.


USAGE
-----

This package is to be used to assist administrators implementing STIG settings within their environment. The administrator must fully test GPOs in test environments prior to live production deployments. The GPOs provided contain most applicable and restrictive GPO STIG settings contained in STIG files. 

The GPO backups are located under the GPO directory in parent STIG directory. Administrators will be required to modify operating system GPOs to reflect the appropriate Enterprise Admins and Domain Admins groups for User Rights Assignments. The GPOs contain ADD YOUR ENTERPRISE ADMINS and ADD YOUR DOMAIN ADMINS text. These can be modified during import of GPO backups if a migration table is used or after import is complete. 

GPOs are split into computer configuration and user configuration were possible. Each GPO has the only the appropriate section enabled within the configured GPO. For example, a GPO identified as a Computer GPO the User Configuration section of GPO is disabled. 

The Office System 2013 and Office System 2016 GPOs contain the IE Security settings from each of the components because of GPO application and precedence.

The WMI Filter files are located under the WMI Filter directory in parent STIG directory. The provided WMI filter exports files are sample WMI filters that can be used to apply to the matching GPO to target the desired operating system or application.

The provided GPO reports provides the administrator ability to review GPO configuration from a browser.

Windows 10 Defender Exploit Protection XML file (DoD_EP_V2.xml) is located under the DoD Windows 10 v1r18 directory. The Exploit Protection "Use a common set of exploit protections settings" setting within the DoD Windows 10 STIG Computer v1r18 GPO must be modified by system administrators from "\\YOUR_FOLDER_SHARE\DoD_EP_V2.xml" to a valid share within production environment. Each enterprise must establish a share to host exploit protection xml and copy the provided xml to enterprise share. The DOD_EP_V2.xml file has all required STIG settings configured. Each of the exploit protection settings are marked open in Windows 10 checklist. 

Delta spreadsheet reports provide the differences between current and previous STIG GPOs.

KNOWN ISSUES
------------
The Windows Server 2008 R2, Windows Server 2012 R2, and Windows Server 2016 member server GPO are configured to the most strictest setting (Local Account instead of Local account and member of Administrators group) for user right assignments values. The setting Deny access to this computer from the network must be relaxed to Local account and member of Administrators group on a system attempting to configured as member of cluster.

The checklist files have been removed from DISA STIG Baseline package. Incompatibilies issues would have delayed release of STIG pacakge.