/**
 * Created by alaputsky on 10/3/2019.
 */

trigger CreateIdentifier on ActorInFilm__c (before insert, before update) {
    CreateIdentifierTriggerHandler.identifierCreation(Trigger.new);
}