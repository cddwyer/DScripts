#!/bin/bash

apiUser=""
apiPass=""

curl -sku $apiUser:$apiPass https://hauserwirth.datajar.mobi/JSSResource/policies | xmllint --format - | grep '<id>' | sed 's/\<id\>//g' | sed 's/\<\/id\>//g' > /tmp/demPols.txt

myPolicies=$(cat /tmp/demPols.txt)


for i in $myPolicies;
do

curl -sS -k -u $apiUser:$apiPass https://hauserwirth.datajar.mobi/JSSResource/policies/id/$i -H "Content-Type: application/xml" -d "<policy><scope><exclusions><computer_groups><computer_group><id>68</id><name>TestExclusion</name></computer_group></computer_groups></exclusions></scope></policy>" -X PUT

done

exit 0

