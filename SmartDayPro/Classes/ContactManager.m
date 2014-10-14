//
//  ContactManager.m
//  SmartPlan
//
//  Created by Huy Le on 12/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <AddressBook/AddressBook.h>

#import "ContactManager.h"

#import "Common.h"
#import "Contacts.h"

ContactManager *_contactManagerSingleton = nil;

@implementation ContactManager

@synthesize contactList;
@synthesize contactDisplayList;
@synthesize locationDisplayListByName;
@synthesize locationDisplayListByContact;
@synthesize indexContactLetters;

- (id) init
{
	if (self = [super init])
	{
		self.contactList = nil;
		self.contactDisplayList = nil;
		self.locationDisplayListByName = nil;
		self.locationDisplayListByContact = nil;
		self.indexContactLetters = nil;
	}
	
	return self;
}

- (NSArray *) getContactList
{
	if (self.contactList != nil)
	{
		return self.contactList;
	}
    
    CFErrorRef error = nil;
	
	ABAddressBookRef addressBook = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")?ABAddressBookCreateWithOptions(NULL, &error): ABAddressBookCreate();
	self.contactList = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
	
	return self.contactList;	
}

- (NSArray *) getContactDisplayList 
{
	if (self.contactDisplayList != nil)
	{
		return self.contactDisplayList;
	}
	
	NSArray *ctactList = [self getContactList];
	
	NSMutableDictionary *indexedContacts = [[NSMutableDictionary alloc] init];
	
	for (int i=0; i< ctactList.count; i++){
		
		ABRecordRef ref = CFArrayGetValueAtIndex((CFArrayRef)contactList,(CFIndex)i);
		
		CFStringRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
		CFStringRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
		CFStringRef company = ABRecordCopyValue(ref, kABPersonOrganizationProperty);
		
		if (firstName==nil && lastName==nil && company==nil){
			firstName=(CFStringRef)_nonameText;
			lastName=(CFStringRef)@" ";
			company=(CFStringRef)@" ";
		}else{
			if(firstName==nil) {
				firstName=(CFStringRef) @" ";
			}
			if(lastName==nil){
				lastName=(CFStringRef)@" ";
			}
			if(company==nil){
				company=(CFStringRef)@" ";
			}
			
		}
		
		NSString *contactName=[NSString stringWithFormat:@"%@ %@",firstName, lastName];
		
		NSString *cName=[contactName copy];
		contactName=[cName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
		contactName=[contactName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
		contactName=[contactName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
		[cName release];
		
		NSString *contactComName=[NSString stringWithFormat:@"%@",company];
		cName=[contactComName copy];
		contactComName=[cName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
		contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
		contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
		[cName release];
		
		////////printf("\n%s",[contactComName UTF8String]);
		NSString *firstLetter; 
		if([[contactName stringByReplacingOccurrencesOfString:@" " withString:@""] length]>0){
			if([[(NSString *)lastName stringByReplacingOccurrencesOfString:@" " withString:@""] length]>0){
				firstLetter= [[(NSString *)lastName substringToIndex:1] uppercaseString];
			}else if([[(NSString *)firstName stringByReplacingOccurrencesOfString:@" " withString:@""] length]>0){
				firstLetter= [[(NSString *)firstName substringToIndex:1] uppercaseString];			
			}else {
				firstLetter=@"Z#";
			}
			
		}else if([contactComName length]>0) {
			contactName=contactComName;
			firstLetter= [[contactComName substringToIndex:1] uppercaseString];
		}else {
			contactName=_nonameText;//@"No Name";
			firstLetter=@"Z#";
		}
		
		
		if([firstLetter compare:@"A"]==NSOrderedAscending  || [firstLetter compare:@"z"]==NSOrderedDescending)
			firstLetter=@"Z#";
		
		NSMutableArray *indexArray = [indexedContacts objectForKey:firstLetter];
		if (indexArray == nil) {
			indexArray = [[NSMutableArray alloc] init];
			[indexedContacts setObject:indexArray forKey:firstLetter];
		}
		
		Contacts *contact=[[Contacts alloc] init];
		contact.contactName=contactName;
		
		NSString *contactLastName=[NSString stringWithFormat:@"%@ %@", lastName,firstName];
		contact.contactLastName=contactLastName;
		
		//get email address from contact
		ABMutableMultiValueRef multiEmailValue = ABRecordCopyValue(ref, kABPersonEmailProperty);
		if(ABMultiValueGetCount(multiEmailValue)>0){
			CFStringRef emailAddr = ABMultiValueCopyValueAtIndex(multiEmailValue, 0);
			
			if(emailAddr==nil){
				emailAddr=(CFStringRef)@" ";	
			}
			contact.emailAddress=[NSString stringWithFormat:@"%@",emailAddr];
		}
        if (multiEmailValue != NULL) {
            CFRelease(multiEmailValue);
        }
		
		
		//get PHONE NUMBER from contact
		ABMutableMultiValueRef phoneEmailValue = ABRecordCopyValue(ref, kABPersonPhoneProperty);
		if(ABMultiValueGetCount(phoneEmailValue)>0){
			contact.phoneNumber=@"";
			
			for(NSInteger i=0;i<ABMultiValueGetCount(phoneEmailValue);i++){
				CFStringRef phoneNo = ABMultiValueCopyValueAtIndex(phoneEmailValue, i);
				CFStringRef label=ABMultiValueCopyLabelAtIndex(phoneEmailValue, i);
				
				if(label==nil){
					label=(CFStringRef)@" ";	
				}
				
				if(phoneNo==nil){
					phoneNo=(CFStringRef)@" ";	
				}
				contact.phoneNumber=[contact.phoneNumber stringByAppendingFormat:@"/%@|%@",label,phoneNo];
			}
			
		}
        if (phoneEmailValue != NULL) {
            CFRelease(phoneEmailValue);
        }
		
		NSString *contactAddress=nil;
		//get first address for this contact
		ABMutableMultiValueRef multiValue = ABRecordCopyValue(ref, kABPersonAddressProperty);
		
		if(ABMultiValueGetCount(multiValue)>0){
			
			//get all address from the contact
			CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, 0);
			CFStringRef street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
			CFStringRef city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
			CFStringRef country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);		
			CFStringRef state = CFDictionaryGetValue(dict,kABPersonAddressStateKey);
			CFStringRef zip = CFDictionaryGetValue(dict,kABPersonAddressZIPKey);
			
            if (dict != NULL) {
                CFRelease(dict);
            }
			
			if(street!=nil){
				contactAddress=[NSString stringWithFormat:@"%@",street];
			}else {
				contactAddress=[NSString stringWithFormat: @""];
			}
			
			if(city!=nil){
				if(street!=nil){
					NSString *cityNameAppend=[NSString stringWithFormat:@", %@",city];
					contactAddress=[contactAddress stringByAppendingString:cityNameAppend];
				}else{
					NSString *cityNameAsLoc=[NSString stringWithFormat:@"%@",city];
					contactAddress=[contactAddress stringByAppendingString:cityNameAsLoc];
				}
			}
			
			if(country!=nil){
				if(![contactAddress isEqualToString:@""]){
					NSString *countryNameAppend=[NSString stringWithFormat:@", %@",country];
					contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
				}else{
					NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",country];
					contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
				}
			}
			
			if(state !=nil){
				if(![contactAddress isEqualToString:@""]){
					NSString *countryNameAppend=[NSString stringWithFormat:@", %@",state];
					contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
				}else{
					NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",state];
					contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
				}
			}
			
			if(zip !=nil){
				if(![contactAddress isEqualToString:@""]){
					NSString *countryNameAppend=[NSString stringWithFormat:@", %@",zip];
					contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
				}else{
					NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",zip];
					contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
				}
			}
			
		}else {
			contactAddress=[NSString stringWithFormat: @""];
		}
		
		contact.contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove the newline character
		contact.contactAddress=[contact.contactAddress stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
		contact.contactAddress=[contact.contactAddress stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
		
		NSDictionary *contactDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:contact, @"contacts", [[contact contactLastName] capitalizedString], @"contactName", nil];
		[indexArray addObject:contactDictionary];
		
		[contact release];
		
        if (multiValue != NULL) {
            CFRelease(multiValue);
        }
		
	}
	
	/*
	 Finish setting up the data structure:
	 Create the contacts array;
	 Sort the used index letters and keep as an instance variable;
	 Sort the contents of the contacts arrays;
	 */
	NSMutableArray *contacts = [[NSMutableArray alloc] init];
	
	// Normally we'd use a localized comparison to present information to the user, but here we know the data only contains unaccented uppercase letters
	
	self.indexContactLetters = [[indexedContacts allKeys] sortedArrayUsingSelector:@selector(compare:)];

	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"contactName" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	for (NSString *indexLetter in self.indexContactLetters)
	{
		NSMutableArray *contactDictionaries = [indexedContacts objectForKey:indexLetter];
		[contactDictionaries sortUsingDescriptors:sortDescriptors];
		
		NSDictionary *letterDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:indexLetter, @"letter", contactDictionaries, @"contacts", nil];
		[contacts addObject:letterDictionary];
		[letterDictionary release];
	}
	[sortDescriptor release];
	
	self.contactDisplayList =[NSArray arrayWithArray: contacts];
	[contacts release];
	[indexedContacts release];
	
	return self.contactDisplayList;
}

- (NSArray *)getLocationDisplayList:(BOOL)isSortByName 
{
	if (self.locationDisplayListByName != nil && isSortByName)
	{
		return self.locationDisplayListByName;
	}
	
	if (self.locationDisplayListByContact != nil && !isSortByName)
	{
		return self.locationDisplayListByContact;
	}	
	
	NSMutableDictionary *indexedContacts = [[NSMutableDictionary alloc] init];
	
	NSArray *ctactList = [self getContactList];
	
	for (int i=0; i< ctactList.count; i++){
		
		ABRecordRef record = [ctactList objectAtIndex:i];
		
		ABMutableMultiValueRef multiValue = ABRecordCopyValue(record, kABPersonAddressProperty);
		
		if(ABMultiValueGetCount(multiValue)>0){
			
			for(int j=0; j<ABMultiValueGetCount(multiValue);j++){//get all address from a contact
				CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, j);
				CFStringRef street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
				CFStringRef city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
				CFStringRef country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);		
				CFStringRef state = CFDictionaryGetValue(dict,kABPersonAddressStateKey);
				CFStringRef zip = CFDictionaryGetValue(dict,kABPersonAddressZIPKey);
				
                if (dict != NULL) {
                    CFRelease(dict);
                }
				
				NSString *locationName;
				if(street!=nil){
					locationName=[NSString stringWithFormat:@"%@",street];
				}else {
					locationName=[NSString stringWithFormat: @""];
				}
				
				if(city!=nil){
					if(street!=nil){
						NSString *cityNameAppend=[NSString stringWithFormat:@", %@",city];
						locationName=[locationName stringByAppendingString:cityNameAppend];
					}else{
						NSString *cityNameAsLoc=[NSString stringWithFormat:@"%@",city];
						locationName=[locationName stringByAppendingString:cityNameAsLoc];
					}
				}
				
				if(country!=nil){
					if(![locationName isEqualToString:@""]){
						NSString *countryNameAppend=[NSString stringWithFormat:@", %@",country];
						locationName=[locationName stringByAppendingString:countryNameAppend];
					}else{
						NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",country];
						locationName=[locationName stringByAppendingString:countryNameAsLoc];
					}
				}
				
				if(state !=nil){
					if(![locationName isEqualToString:@""]){
						NSString *countryNameAppend=[NSString stringWithFormat:@", %@",state];
						locationName=[locationName stringByAppendingString:countryNameAppend];
					}else{
						NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",state];
						locationName=[locationName stringByAppendingString:countryNameAsLoc];
					}
				}
				
				if(zip !=nil){
					if(![locationName isEqualToString:@""]){
						NSString *countryNameAppend=[NSString stringWithFormat:@", %@",zip];
						locationName=[locationName stringByAppendingString:countryNameAppend];
					}else{
						NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",zip];
						locationName=[locationName stringByAppendingString:countryNameAsLoc];
					}
				}
				
				NSString *locFull=[locationName copy];
				locationName=[locFull stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
				locationName=[locationName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
				locationName=[locationName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove ; character;
				
				[locFull release];
				
				if( !isSortByName){
					
					NSString *firstLetter;
					if([[locationName stringByReplacingOccurrencesOfString:@" " withString:@""] length]<1){
						firstLetter=@"Z#";
					}else {
						firstLetter = [[locationName substringToIndex:1] uppercaseString];
					}
					
					if([firstLetter compare:@"A"]==NSOrderedAscending  || [firstLetter compare:@"z"]==NSOrderedDescending)
						firstLetter=@"Z#";
					
					NSMutableArray *indexArray = [indexedContacts objectForKey:firstLetter];
					if (indexArray == nil) {
						indexArray = [[NSMutableArray alloc] init];
						[indexedContacts setObject:indexArray forKey:firstLetter];
						//[indexArray release];
					}
					NSDictionary *contactDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:locationName, @"locations", locationName, @"locationLocaleName", nil];
					[indexArray addObject:contactDictionary];
					[contactDictionary release];
					
				}else {
					//ABRecordRef ref = CFArrayGetValueAtIndex((CFArrayRef)contactList,(CFIndex)i);
					
					CFStringRef firstName = ABRecordCopyValue(record, kABPersonFirstNameProperty);
					CFStringRef lastName = ABRecordCopyValue(record, kABPersonLastNameProperty);
					
					if (firstName==nil && lastName==nil){
						firstName=(CFStringRef)@"No name";
						lastName=(CFStringRef)@" ";
					}else if(firstName==nil) {
						firstName=(CFStringRef) @" ";
					}else if(lastName==nil){
						lastName=(CFStringRef)@" ";
					}
					
					NSString *contactName=[[NSString  alloc] initWithFormat:@"%@ %@",firstName, lastName];
					
					NSString *firstLetter = contactName;
					NSMutableArray *indexArray = [indexedContacts objectForKey:firstLetter];
					if (indexArray == nil) {
						indexArray = [[NSMutableArray alloc] init];
						[indexedContacts setObject:indexArray forKey:firstLetter];

					}
					NSDictionary *contactDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:locationName, @"locations", locationName, @"locationLocaleName", nil];
					[indexArray addObject:contactDictionary];
					[contactDictionary release];
					[contactName release];
				}
			}
		}
        
        if (multiValue != NULL) {
            CFRelease(multiValue);
        }
	}
	
	/*
	 Finish setting up the data structure:
	 Create the contacts array;
	 Sort the used index letters and keep as an instance variable;
	 Sort the contents of the contacts arrays;
	 */
	NSMutableArray *locations = [[NSMutableArray alloc] init];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"locationLocaleName" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	NSString *indexLetterTmp;
	NSArray *indexLetters=isSortByName? [[indexedContacts allKeys] sortedArrayUsingSelector:@selector(compare:)]: [[indexedContacts allKeys] sortedArrayUsingSelector:@selector(compare:)];
	for (indexLetterTmp in indexLetters) {		
		NSMutableArray *locaionDictionaries = [indexedContacts objectForKey:indexLetterTmp];
		[locaionDictionaries sortUsingDescriptors:sortDescriptors];
		
		NSString *indexLetter= [indexLetterTmp copy];
		NSDictionary *letterDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:indexLetter, @"letter", locaionDictionaries, @"locations", nil];
		[locations addObject:letterDictionary];
		[indexLetter release];
		[letterDictionary release];
	}
	[sortDescriptor release];
	
	if(isSortByName){
		self.locationDisplayListByName = [NSArray arrayWithArray:locations];
		
	}else {
		self.locationDisplayListByContact = [NSArray arrayWithArray:locations];
	}
	
	[locations release];
	[indexedContacts release];

	return isSortByName?self.locationDisplayListByName:self.locationDisplayListByContact;
}

- (void)dealloc 
{
	self.contactList = nil;
	self.contactDisplayList = nil;
	self.locationDisplayListByName = nil;
	self.locationDisplayListByContact = nil;	
	self.indexContactLetters = nil;
	
	[super dealloc];
}

+(id)getInstance
{
	if (_contactManagerSingleton == nil)
	{
		_contactManagerSingleton = [[ContactManager alloc] init];
	}
	
	return _contactManagerSingleton;
}

+(void)free
{
	if (_contactManagerSingleton != nil)
	{
		[_contactManagerSingleton release];
	}
}

@end
