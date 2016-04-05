#interface with gethilingual.com!!!!!!
#nateohlson 2016
import sys
import urllib3
import certifi
import json
import ast

userSessionId = ""
userId = ""
loggedin = 0

http = urllib3.PoolManager(
	cert_reqs="CERT_REQUIRED",
	ca_certs=certifi.where())



# POST    /tasks/log-level (io.dropwizard.servlets.tasks.LogConfigurationTask)
# POST    /tasks/gc (io.dropwizard.servlets.tasks.GarbageCollectionTask)
# POST    /tasks/apns-test (com.example.hilingual.server.task.ApnsTestTask)
# POST    /tasks/revoke-all-sessions (com.example.hilingual.server.task.RevokeAllSessionsTask)
# POST    /tasks/truncate-databases (com.example.hilingual.server.task.TruncateTask)

def showChats():
	global userinfo

	chatuserids = str(userinfo['usersChattedWith'])[1:-1].split()


	print("\nCurrent chats with:")

	for i in chatuserids:
		tempdict = getOtherProfileInfo(int(i))
		print(str(i) + " " + str(tempdict['displayName']))





def editMessage():
	global responsebody
	global userSessionId
	global userId

	messageId = input("Enter the id of the message you would like to edit: ")

	auth_param = "HLAT " + userSessionId
	url = 'https://gethilingual.com/api/chat/' + str(userId) + "/message/" + str(messageId)

	editdata = input("Enter edit: ")

	data = "{\"id\":\"" + str(messageId) + "\",\"editData\":\"" + str(editdata) + "\"}"

	response = http.request('PATCH', url, headers={'Authorization':auth_param, 'Content-Type':'application/json'}, body=data)

	if response.status != 200:
		print("Error: returned status code: " + str(response.status))
		responsebody = response.data.decode('utf-8')
		parsed_me_responsebody = json.loads(responsebody)
		print(parsed_me_responsebody)
	else:
		print("Edit sent!\n")





def receiveMessages():
	global responsebody
	global userSessionId
	global userId

	auth_param = "HLAT " + userSessionId

	otheruser = input("Enter id of other user: ")

	url = 'https://gethilingual.com/api/chat/' + str(otheruser) + "/message"


	response = http.request('GET', url, headers={'Authorization':auth_param})

	

	responsebody = response.data.decode('utf-8')
	parsed_search_responsebody = json.loads(responsebody)

	#get information about other user in chat
	otheruserparsed = getOtherProfileInfo(otheruser)
	otherusername = str(otheruserparsed['displayName'])

	print("\n\nChat between you and " + str(otherusername))


	count = 0
	for i in parsed_search_responsebody:
		tempdict = ast.literal_eval(str(i))
		addfrom = ""
		addto = ""
		frompad = ""
		if tempdict['sender'] == userId:
			addfrom = " (you)"
			frompad = "          "
		elif tempdict['sender'] == int(otheruser):
			addfrom = " (" + otherusername + ")"
		if tempdict['receiver'] == userId:
			addto = " (you)"
		elif tempdict['receiver'] == int(otheruser):
			addto = " (" + otherusername +  ")"

		print("----------- Message " + str(count) +" -----------")
		print(str(frompad) + "Message ID: " + str(tempdict['id']))
		print(str(frompad) + "From: " + str(tempdict['sender']) + addfrom)
		print(str(frompad) + "To: " + str(tempdict['receiver']) + addto)
		print(str(frompad) + "Time: " + str(tempdict['sentTimestamp']))
		print(str(frompad) + "Message:")
		print(str(frompad) + tempdict['content'])
		print()

		count += 1





def sendMessage():
	global responsebody
	global userSessionId
	global userId

	auth_param = "HLAT " + userSessionId
	url = 'https://gethilingual.com/api/chat/'

	requestuserid = input("Enter the userid of the user you want to send a message: ")
	url = url + str(requestuserid) + "/message"
	message = input("Enter message: ")

	bodydic = "{\"content\": \""+ message + "\"}"
	print(bodydic)

	response = http.request('POST', url, headers={'Content-Type':'application/json', 'Authorization':auth_param}, body=bodydic)

	if response.status != 200:
		print("Error: returned status code: " + str(response.status))
		responsebody = response.data.decode('utf-8')
		parsed_me_responsebody = json.loads(responsebody)
		print(parsed_me_responsebody)
	else:
		print("Message sent!\n")




def acceptChatRequest():
	global responsebody
	global userSessionId
	global userId

	url = 'https://gethilingual.com/api/chat/'
	auth_param = "HLAT " + userSessionId

	requestuserid = input("Enter the userid of the user you want to accept chat request: ")

	url = url + requestuserid + "/accept"

	response = http.request('POST', url, headers={'Authorization':auth_param})
	
	if response.status != 204:
		print("Error: returned status code: " + str(response.status))

	else:
		print("Request success")


def requestToChatWithUser():
	global responsebody
	global userSessionId
	global userId

	url = 'https://gethilingual.com/api/chat/'
	auth_param = "HLAT " + userSessionId

	requestuserid = input("Enter the userid of the user you want to request to chat: ")

	url = url + str(requestuserid)

	response = http.request('POST', url, headers={'Authorization':auth_param})
	
	if response.status != 204:
		print("Error: returned status code: " + str(response.status))
	else:
		print("Request success")



def messagesMe():
	global responsebody
	global userSessionId
	global userId

	url = 'https://gethilingual.com/api/chat/me'

	auth_param = "HLAT " + userSessionId

	response = http.request('GET', url, headers={'Authorization':auth_param})
	if response.status != 200:
		print("Error: returned status code: " + str(response.status))


	responsebody = response.data.decode('utf-8')
	parsed_me_responsebody = json.loads(responsebody)

	print("status: " + str(response.status))

	print(parsed_me_responsebody)


def messagesPortal():
	global responsebody
	global userSessionId
	global userId

	url = 'https://gethilingual.com/api/chat'
	print("\nMessages Portal")

	while 1:
		print("\n\n1)ME\n2)Request to Chat With User\n3)Accept Chat Request\n4)Send message\n5)Receive Messages\n6)Edit Message\n7)Show current chats\n8)Exit")
		selection = input("Select task>")

		if selection == "1":
			messagesMe()
		elif selection == "2":
			requestToChatWithUser()
		elif selection == "3":
			acceptChatRequest()
		elif selection == "4":
			sendMessage()
		elif selection == "5":
			receiveMessages()
		elif selection == "6":
			editMessage()
		elif selection == "7":
			showChats()
		else:
			return







def adminActions():
	url = 'http://gethilingual.com:8082/api/admin/tasks/'

	while 1:

		print("1) log-level\n2) gc\n3) apns-test\n4) revoke-all-sessions\n5) truncate-databases\n5) exit")
		selection = input("Select task>")

		if selection == "1":
			url = url + "log-level"
		elif selection == "2":
			url = url + "gc"
		elif selection == "3":
			url = url + "apns-test"
		elif selection == "4":
			url = url + "revoke-all-sessions"
		elif selection == "5":
			url = url + "truncate-databases"
		elif selection == "5":
			pass
		else:
			print("Invalid selection")

		print("Outgoing request to: " + url)

		response = http.request('POST', url)
		if response.status != 200:
			print("Error: returned status code: " + str(response.status))

	



def searchUsers():
	global responsebody
	global userSessionId
	global userId

	query = input("Search: ")
	url = 'https://gethilingual.com/api/user/search'

	auth_param = "HLAT " + userSessionId

	response = http.request('GET', url, {'query':query}, headers={'Authorization':auth_param})
	if response.status != 200:
		print("Error: returned status code: " + str(response.status))
		return {}

	responsebody = response.data.decode('utf-8')
	parsed_search_responsebody = json.loads(responsebody)

	return parsed_search_responsebody

def updateUserInfo(previous):
	global responsebody
	global userSessionId
	global userId

	print("Fields:\n    1:user_name\n    2:display_name\n    3:bio\n    4:gender(male/female)\n    5:birth_date(epochseconds)\n    6:image_url\n")

	fieldnum = input("\nEnter the field number you would like to edit: ")
	newval = input("Enter new value: ")

	if fieldnum == "1":
		previous.pop("name")
		previous["name"] = str(newval)
	elif fieldnum == "2":
		previous.pop("displayName")
		previous["displayName"] = str(newval)
	elif fieldnum == "3":
		previous.pop("bio")
		previous["bio"] = str(newval)
	elif fieldnum == "4":
		previous.pop("gender")
		previous["gender"] = str(newval).upper()
	elif fieldnum == "5":
		previous.pop("birthdate")
		previous["birthdate"] = str(newval)
	elif fieldnum == "6":
		previous.pop("imageURL")
		previous["imageURL"] = str(newval)

	url = 'https://gethilingual.com/api/user/' + str(userId)

	auth_param = "HLAT " + str(userSessionId)
	data = json.dumps(previous)

	response = http.request('PATCH', url, headers={'Content-Type':'application/json', 'Authorization':auth_param}, body=data)

	if response.status !=200:
		print("FAILED TO UPDATE USER")
		print("Error returned status code: " + str(response.status) + "\n\n")
		return 0

	print("\nSuccessful update\n\n")

def printUsersInfo(parsedjson):
	print("\nYOUR PROFILE:")
	if "userId" in parsedjson:
		print("    userId: " + str(parsedjson["userId"]))
	if "name" in parsedjson:
		print("    Name: " + parsedjson["name"])
	if "displayName" in parsedjson:
		print("    Display Name: " + parsedjson["displayName"])
	if "bio" in parsedjson:
		print("    Bio: " + parsedjson["bio"])
	if "gender" in parsedjson:
		print("    Gender: " + parsedjson["gender"])
	if "birthdate" in parsedjson:
		print("    Birthdate: " + str(parsedjson["birthdate"]))
	if "imageURL" in parsedjson:
		print("    imageURL: " + parsedjson["imageURL"])
	if "knownLanguages" in parsedjson:
		print("    Known Languages: " + str(parsedjson["knownLanguages"]))
	if "learningLanguages" in parsedjson:
		print("    Learning Languages: " + str(parsedjson["learningLanguages"]))
	if "blockedUsers" in parsedjson:
		print("    Blocked Users: " + str(parsedjson["blockedUsers"]))
	if "usersChattedWith" in parsedjson:
		print("    Users Chatted With: " + str(parsedjson["usersChattedWith"]))

	print("\n")


def printUsersInfoSearch(parsedjson):
	print("Returned user information:")
	print(parsedjson)

	if parsedjson:
		print(len(parsedjson))
		for subdict in parsedjson:
			print("USER: " + subdict["displayName"])
			for subkey in subdict:
				print("    " + subkey + ": " + str(subdict[subkey]))
			print("\n\n")

		
	else:
		print("No results")

def logout():
	url = 'https://gethilingual.com/api/auth/'+ str(userId) + '/logout'

	auth_param = "HLAT " + userSessionId

	data = '{"UserId":"' + str(userId) + '"}'

	print(auth_param)

	response = http.request('POST', url, headers={'Content-Type':'application/json','Authorization':auth_param}, body=data)
	if response.status != 204:
		print("error")
		print(response.data)
		return 0

	print("LOGOUT SUCCESSFUL. GOODBYE")

	sys.exit(1)

def getOtherProfileInfo(thisid):
	global responsebody
	global userSessionId

	url = 'https://gethilingual.com/api/user/' + str(thisid)

	auth_param = "HLAT " + userSessionId

	data = '{"thisid":"' + str(thisid) + '"}'

	response = http.request('GET', url, headers={'Content-Type':'application/json', 'Authorization':auth_param}, body=data)
	if response.status != 200:
		print("Error: returned status code: " + str(response.status))
		return {}

	responsebody = response.data.decode('utf-8')
	parsed_user_responsebody = json.loads(responsebody)

	return parsed_user_responsebody

def getProfileInfo():
	global responsebody
	global userSessionId
	global userId

	url = 'https://gethilingual.com/api/user/' + str(userId)

	auth_param = "HLAT " + userSessionId

	data = '{"userId":"' + str(userId) + '"}'

	response = http.request('GET', url, headers={'Content-Type':'application/json', 'Authorization':auth_param}, body=data)
	if response.status != 200:
		print("Error: returned status code: " + str(response.status))
		return {}

	responsebody = response.data.decode('utf-8')
	parsed_login_responsebody = json.loads(responsebody)

	return parsed_login_responsebody

def userview():
	global userinfo
	userinfo = getProfileInfo()

	print("\n\nLOGIN SUCCESS")
	while 1:
		print("\n\n1:Get My Profile Info\n2:Get Another user profile info\n3:Update profile\n4:Search users\n5:Messages Portal\n6:Logout")
		decision = input("What would you like to do>")
		if decision == "1":
			returned = getProfileInfo()
			printUsersInfo(returned)
		elif decision == "2":
			otherid = input("Enter the id number of user: ")
			returned = getOtherProfileInfo(otherid)
			printUsersInfo(returned)
		elif decision == "3":
			returned = getProfileInfo()
			updateUserInfo(returned)
		elif decision == "4":
			returned = searchUsers()
			printUsersInfoSearch(returned)
		elif decision == "5":
			messagesPortal()

		elif decision == "6":
			logout()

def login():
	global http
	global userSessionId
	global responsebody
	global userId

	url = 'https://gethilingual.com/api/auth/login'

	authority = input("What is the name of the authorization authority:\n    1)Facebook\n    2)Google\n>")
	if authority == "1":
		authority = "FACEBOOK"
	elif authority == "2":
		authority = "GOOGLE"
	authorityAccountId = input("Enter authority account id:")
	authorityToken = input("Enter authority token:")

	#hardcoded for testing
	# authority = "FACEBOOK"
	# authorityAccountId = "100844556977738"
	# authorityToken = "CAAOcGlfuCWEBAEAyq4qdPZAisXgJ50LLcASiITW9QZCArmZCWjepDWqlZCXqfH4qpHxJFb6R3YyxdcZAlVsGZBdC7JgvTQ6RgU4EncrUWYeKgCaROXC2ImOUv7cK5fTf5JyRwuyMTHbg0nZBTeKZC7Siqs2cIDgfJgDUGnQH83gCmT5PZAZBHDoJseJTNUg1ZCZCy3dDu0ArcmhmRGonIVNxpRq3"

	data = '{"authority":"'
	data = data + authority + '","authorityAccountId":"'
	data = data + authorityAccountId + '","authorityToken":"'
	data = data + authorityToken + '"}'

	response = http.request('POST', url, headers={'Content-Type':'application/json'}, body=data)
	responsebody = response.data.decode("utf-8")

	if response.status != 200:
		print("error")
		print(responsebody)
		return 0
	print(responsebody)
	parsed_login_responsebody = json.loads(responsebody)
	userSessionId = parsed_login_responsebody["sessionId"]
	userId = parsed_login_responsebody["userId"]
	print("SessionID: " + userSessionId)
	print("UserID: " + str(userId))
	return 1

def register():
	url = 'https://gethilingual.com/api/auth/register'

	authority = input("What is the name of the authorization authority:")
	authorityAccountId = input("Enter authority account id:")
	authorityToken = input("Enter authority token:")
	data = '{"authority":"'
	data = data + authority + '","authorityAccountId":"'
	data = data + authorityAccountId + '","authorityToken":"'
	data = data + authorityToken + '"}'


	response = http.request('POST', url, headers={'Content-Type':'application/json'}, body=data)
	responsebody = response.data.decode("utf-8")
	if response.status != 200:
		print("error")
		print(responsebody)
		return 0
	print(responsebody)
	parsed_login_responsebody = json.loads(responsebody)
	userSessionId = parsed_login_responsebody["sessionId"]
	userId = parsed_login_responsebody["userId"]
	print("SessionID: " + userSessionId)
	print("UserID: " + str(userId))
	return 1

def main():
	global loggedin

	while 1:
		option = initview()

		success = 0
		if option == "1":
			success = login()
		elif option == "2":
			success = register()
		elif option == "3":
			adminActions()
		if success == 1:
			loggedin = 1
			userview()

		else:
			print("There was an error logging in")
			sys.exit(1)


def initview():
	print("\n\n1:Login\n2:Register\n3:Admin Tasks")
	decision = input("What would you like to do>")
	return decision




try:
	main()
	# for debugging
	# login()
	# userview()
except KeyboardInterrupt:
	if loggedin == 1:
		logout()
