# Postgresql Snowflake Migration

# Using this Template

## Clone and Clean the template (if using GitHub)
* Navigate to: https://github.com/NRD-Tech/flyway-postgres.git
* Log into your GitHub account (otherwise the "Use this template" option will not show up)
* Click "Use this template" in the top right corner
  * Create a new repository
* Fill in your repository name, description, and public/private setting
* Clone your newly created repository
* If you want to change the license to be proprietary follow these instructions: [Go to Proprietary Licensing Section](#how-to-use-this-template-for-a-proprietary-project)

## Clone and Clean the template (if NOT using GitHub)
```
git clone https://github.com/NRD-Tech/flyway-postgres.git my-project
cd my-project
rm -fR .git venv .idea
git init
git add .
git commit -m 'init'
```
* If you want to change the license to be proprietary follow these instructions: [Go to Proprietary Licensing Section](#how-to-use-this-template-for-a-proprietary-project)

## Initial Setup
1. As the default postgres user, create the database
	```
	create database mydb;
	```
2. Docker must be installed.

## Pipeline Setup
* Configure the following Bitbucket environment variables
  * HOST (per environment)
	* Hostname for the production postgresql instance
  * PORT
  	* Usually 5432
  * DB
	* Name of the database
  * SCHEMA
    * Schema in the database
  * USER
  	* Username of the user that will do the migrations
  * PASS
	* This should be configured per environment
	* Expect the value to come from the environment secrets

### Deploy to Staging
```
git checkout -b staging
git push --set-upstream origin staging
```

### Deploy to Production
```
git checkout -b production
git push --set-upstream origin production
```

## Creating a New Versioned Migration
* Add a new file to the migration/ folder
* The new file must be in this format:
	* V{CURRENT DATE TIME DOWN TO THE SECOND}__some_description_using_underscores.sql
		* It must start with a capital "V"
		* It must have a date time stamp down to the second in this format: YYYYMMDDHHmmss
		* There must be two underscores "__" between the date time stamp and the description
		* The description should explain briefly what you are doing
		* It must end in .sql
		* Example: V20230116103300__create_user_table.sql

## Creating a Repeatable Versioned Migration
* NOTE: Only Functions, Stored Procedures, or Views should be set up as repeatable migrations
* Add a new file to the static/* folder
* The new file must be in this format:
	* R__l{LEVEL_NUMBER}_some_description_using_underscores.sql
		* It must start with a capital "R"
		* There must be a "level" indicator that is the letter "l" with an integer following
		  * This makes it possible to specify dependency levels.
		  * For Example: If you have a view that requires a function to be created first you would name your migrations like this:
		    * R__l1_myfunction.sql
			* R__l2_my_view_that_needs_myfunction.sql
		* There must be two underscores "__" between the "R" and the description
		* The description should explain briefly what you are doing
		* It must end in .sql
		* Example: R__l2_valid_users_v.sql

## Development Process
* When adding changes to the database, a developer should first branch off the "main" branch and create a new branch named feature/my-feature-description or bugfix/my-bug-fix-description with an appropriate name
* The developer should make their changes and then run the flyway migration on their own local database.  The developer can then test those changes with local code without impacting the staging or production environments.
* Once the feature or bugfix is working, the change should be merged into main to incorporate any other current changes from other developers.
* The developer should migrate their developer database again from the main branch to make sure it is working in case other developers have also added things
    * NOTE: It is likely when you merge into main that you will incorporate migrations from other developers that have different version numbers that have been mixed into the migration history.  This will cause your migration to fail in your database.  The best way to handle this is to specify a new SCHEMA in the environment variables.  You can create as many SCHEMA's as you like in your own database.  Something like MYTEST20230716 might be a good name for a schema.  By just creating a new schema you can avoid having to manually fix your flyway_schema_history table to work when merging with work from other developers.
* Once a developer has successfully migrated the main branch in their development database and tested the changes with their application code, they can submit a pull request to go to the "staging" branch.  One the pull request is reviewed, approved, and merged the CI/CD system will automatically migrate the staging database.
* Once the developer has tested their application in staging, the developer can submit a pull request to go to the production branch.  Once that pull request has been reviewed, approved, and merged the CI/CD system will automatically migrate the production database.

## Using Environment in Migrations
* Sometimes you have a need to specify an environment variable in the migration.  You can do this in the SQL by using {{ENV}} in the statement.
* A perfect example of this scenario is when you want to have different sources of data for production, staging, and developer environments.  This allows developers to load a smaller set of data into their developer database so to avoid huge costs.
* Example:
```
CREATE EXTENSION aws_s3 CASCADE;
SELECT aws_s3.table_import_from_s3(
	'my_table', -- target table
	'', -- column list (empty means all columns)
	'(FORMAT CSV)', -- additional copy options
	'my-bucket', -- S3 bucket
	'{{ENV}}/my_table/my-data.csv' -- S3 object key
);
```

## Running Staging and Production Migrations
* These should be done through bitbucket or some other CI/CD system when the code is merged into the staging and production branches.

## Running Staging and Production Repairs
* Occassionally a migration will fail to execute and will require flyway to run a repair to clean up the migration meta data.  In these cases a user can manually execute repair for Staging and Production through the CI/CD user interface.

## Running Migrations
* Developers can have their own local database for development and testing.  Developers should run migrations locally.
* Example:
```
# Start postgres in docker
docker run --rm --name mycompany-db -e POSTGRES_PASSWORD=dev -p 5432:5432 -d postgres

# Create mydb
PGPASSWORD=dev psql -h localhost -p 5432 -U postgres -d postgres -c "create database mydb"

# Run migration
ENVIRONMENT=dev ./migrate.sh
```

## Running Repair for Developer-Specific Databases
* Occassionally a migration will fail to execute and will require flyway to run a repair to clean up the migration meta data.
```
# Run migration
ENVIRONMENT=dev ./repair.sh
```

## Connect to local
```
PGPASSWORD=dev psql -h localhost -p 5432 -U postgres -d mydb
```
