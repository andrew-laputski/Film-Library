POST method
{
   "films":[
      {
         "film":{
            "Name__c":"Film 1"
         },
         "actors":[
            {
               "actor":{
                  "Name__c":"Actor 10"
               }
            }

         ]
      },
      {
         "film":{
            "Name__c":"Film 13"
         },
         "actors":[
            {
               "actor":{
                  "Name__c":"Actor 13"
               }
            },
            {
               "actor":{
                  "Name__c":"Actor 1"
               }
            }

         ]
      },
      {
         "film":{
            "Name__c":"Film 14"
         },
         "actors":[
            {
               "actor":{
                  "Name__c":"Actor 14"
               }
            }

         ]
      },
      {
         "film":{
            "Name__c":"Film 15"
         },
         "actors":[
            {
               "actor":{
                  "Name__c":"Actor 1"
               }
            }

         ]
      },
      {
         "film":{
            "Name__c":"Film 1"
         },
         "actors":[
            {
               "actor":{
                  "Name__c":"Actor 15"
               }
            }

         ]
      },
      {
         "film":{
            "Name__c":"Film 16"
         },
         "actors":[

         ]
      },
      {
         "film":{
            "Name__c":"Film 2"
         },
         "actors":[

         ]
      }
   ]
}

DELETE method
/services/apexrest/FilmLibrary/?json={"films":[{"film":{"Name__c":"Film+1"},"actors":[{"actor":{"Name__c":"Actor+10"}}]},{"film":{"Name__c":"Film+13"},"actors":[{"actor":{"Name__c":"Actor+13"}},{"actor":{"Name__c":"Actor+1"}}]},{"film":{"Name__c":"Film+14"},"actors":[{"actor":{"Name__c":"Actor+14"}}]},{"film":{"Name__c":"Film+15"},"actors":[{"actor":{"Name__c":"Actor+1"}}]},{"film":{"Name__c":"Film+1"},"actors":[{"actor":{"Name__c":"Actor+15"}}]},{"film":{"Name__c":"Film+16"},"actors":[]},{"film":{"Name__c":"Film+2"},"actors":[]}]}