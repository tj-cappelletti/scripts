#!/bin/bash

set -m

# Launch SQL Server as a background process
# Direct stdout to null but allow errors to be written to the console
echo "Starting SQL Server..."
/opt/mssql/bin/sqlservr &

# Give SQL Server a chance to start up
sleep 15

# Loop to wait for SQL Server to startup
while [ $sqlCheckCount -lt 4 ]
do
	# Try a command that will tell us if SQL Server is running
	# Dump all output to null, we expect some errors while starting
	echo "Checking if SQL Server has started..."
	/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -Q "SELECT TOP 1 * FROM sys.dabases" > /dev/null 2>&1

	# Break loop if the query was sucessful
	if [ $? -eq 0 ]
	then
		sqlCheckCount=5
		sqlIsAlive=1
	else
		echo "Query check failed..."
		sqlCheckCount=$(( $sqlCheckCount + 1))
		echo "Waiting for SQL Server to start..."
		sleep 5
	fi
done

# If SQL Server didn't start, return a non-successful code
if [ $sqlIsAlive -eq 0 ]
then
	echo "SQL Server failed to start in a timely manner..."
	exit 1
fi

echo "SQL Server is running, attaching database..."
# Move the MDF file into the data directory
# If the MDF file is in the data directory at start
# SQL Server does something really weird and act
# like it is on a Windows box and stops working
mv /var/opt/mssql/tsa-coding-submissions.mdf /var/opt/mssql/data/tsa-coding-submissions.mdf

# Attach the MDF file
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $SA_PASSWORD -Q "CREATE DATABASE [tsa-coding-submissions] ON ( FILENAME = N'/var/opt/mssql/data/tsa-coding-submissions.mdf' ) FOR ATTACH"

fg %1