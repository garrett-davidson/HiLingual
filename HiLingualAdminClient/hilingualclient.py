#interface with gethilingual.com!!!!!!
import sys
import urllib3
import certifi
import json


userSessionId = ""
userId = ""


http = urllib3.PoolManager(
	cert_reqs="CERT_REQUIRED",
	ca_certs=certifi.where())



def searchUsers

def updateUserInfo():
	pass



def printUsersInfo(parsedjson):
	print("Returned user information:")

	for user in parsedjson:
		if "userId" in user:
			print("    userId: " + user["userId"])
		if "name" in user:
			print("    Name: " + user["name"])
		if "displayName" in user:
			print("    Display Name: " + user["displayName"])
		if "bio" in user:
			print("    Bio: " + user["bio"])
		if "gender" in user:
			print("    Gender: " + user["gender"])
		if "birthdate" in user:
			print("    Birthdate: " + user["birthdate"])
		if "imageURL" in user:
			print("    imageURL: " + user["imageURL"])
		if "knownLanguages" in user:
			print("    Known Languages:")
			for x in user["knownLanguages"]:
				print("        " + x)
		if "learningLanguages" in user:
			print("    Learning Languages:")
			for x in user["learningLanguages"]:
				print("        " + x)
		if "blockedUsers" in user:
			print("    Blocked Users:")
			for x in user["blockedUsers"]:
				print("        " + x)
		if "usersChattedWith" in user:
			print("    Users Chatted With:")
			for x in user["usersChattedWith"]:
				print("        " + x)



def logout():
	url = 'https://gethilingual.com/api/auth/'+ str(userId) + '/logout'

	auth_param = "HLAT " + userSessionId

	data = '{"userId":"' + str(userId) + '"}'

	print(auth_param)

	response = http.request('POST', url, headers={'Content-Type':'application/json','Authorization':auth_param}, body=data)
	if response.status != 204:
		print("error")
		print(response.data)
		return 0

	print("LOGOUT SUCCESSFUL. GOODBYE")

	sys.exit(1)



def getProfileInfo():
	global responsebody
	global userSessionId
	global userId

	url = 'https://gethilingual.com/api/user/' + userId

	auth_param = "HLAT " + userSessionId

	data = '{"userId":"' + userId + '"}'

	response = http.request('GET', url, headers={'Content-Type':'application/json', 'Authorization':auth_param}, body=data)
	if response.status != 200:
		print("Error: returned status code: " + response.status)
		return {}

	responsebody = response.data.decode('utf-8')
	parsed_login_responsebody = json.loads(responsebody)

	return parsed_login_responsebody




def userview():
	print("LOGIN SUCCESS")
	while 1:
		print("1:Get My Profile Info\n2:Get user profile info\n3:Update profile\n4:Search users\n5:Logout")
		decision = input("What would you like to do>")
		if decision == "1":
			getProfileInfo()
		elif decision == "2":
			returned = getProfileInfo()
			printUsersInfo(returned)
		elif decision == "3":
			returned = getProfileInfo()
			updateUserInfo(returned)
		elif decision == "4":
			returned = searchUsers()
			printUsersInfo(returned)

		elif decision == "5":
			logout()





def login():
	global http
	global userSessionId
	global responsebody
	global userId

	url = 'https://gethilingual.com/api/auth/login'

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


	


def register():
	url = 'https://gethilingual.com/api/auth/register'

	authority = input("What is the name of the authorization authority:")
	authorityAccountId = input("Enter authority account id:")
	authorityToken = input("Enter authority token:")
	data = '{"authority":"'
	data = data + authority + '","authorityAccountId":"'
	data = data + authorityAccountId + '","authorityToken":"'
	data = data + authorityToken + '"}'


	response = requests.get(url, data=data)





def main():

	while 1:
		option = initview()

		success = 0
		if option == "1":
			success = login()
		elif option == "2":
			success = register()

		if success == 1:
			userview()
		else:
			print("There was an error logging in")
			sys.exit(1)






def initview():
	print("1:Login\n2:Register")
	decision = input("What would you like to do>")
	return decision







main()