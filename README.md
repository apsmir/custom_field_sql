Redmine sql custom field
==================
This plugin add sql format for custom fields.

Compatibility
-------------
* Redmine 3.4.0 or higher

Installation
----------------------
* Clone or [download](https://github.com/apsmir/custom_field_sql/archive/master.zip) this repo into your **redmine_root/plugins/** folder

```
$ git clone https://github.com/apsmir/custom_field_sql.git
```
* If you downloaded this repo, make sure to rename the extracted folder to `custom_field_sql`
* Restart Redmine

Usage
----------------------
1) Visit **Administration->Custom fields**. 
2) Press the button **New custom field**. Select format **Sql**.
3) Enter sql query 

Uninstall
----------------------
1) Delete all custom fields with format Sql.
2) Remove folder **redmine_root/plugins/custom_field_sql**
3) Restart Redmine
