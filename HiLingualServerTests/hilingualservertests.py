#hilingual automated tests
#nateohlson

import sys
import json
import urllib3
import certifi
import ast
import signal

http = urllib3.PoolManager(
	cert_reqs="CERT_REQUIRED",
	ca_certs=certifi.where())


def test8():
	print("Test 10: Recieve Message")

def test7():
	print("Test 9: Send Message")


def test6():
	print("Test 8: Accept Chat")


def test5():
	print("Test 7: Request Chat")

def test4():
	print("Test 6: Search Users")


def test3():
	global userIdUser1
	global userSessionIdUser1
	global userIdUser2
	global userSessionIdUser2

	print("Test 3: Get Profile Info")

	print("3.1")




def test2():
	global userSessionIdUser1
	global responsebody
	global userIdUser1
	global userSessionIdUser2
	global userIdUser2
	global authAuthorityUser1
	global authAuthorityUser2
	global authorityAccountIdUser1
	global authorityAccountIdUser2
	global authorityTokenUser1
	global authorityTokenUser2

	url = 'https://gethilingual.com/api/auth/login'
	print("Test 2: Login")


	print("2.1 Test invalid login credentials...")


	#####2.1.1 Invalid OAuth Authority##################################
	print("2.1.1 Invalid OAuth Authority...")

	authority = "REDDIT"
	authorityAccountId = authorityAccountIdUser1
	authorityToken = authorityTokenUser1
	data = '{"authority":"'
	data = data + authority + '","authorityAccountId":"'
	data = data + authorityAccountId + '","authorityToken":"'
	data = data + authorityToken + '"}'

	print("Sending: " + str(data))

	response = http.request('POST', url, headers={'Content-Type':'application/json'}, body=data)

	responsebody = response.data.decode('utf-8')
	parsed = json.loads(responsebody)
	print("Unable to process JSON expected...")
	if response.status != 400:
		print(parsed)
		print("Test 2.1.1 Failed")
		sys.exit(1)
	else:
		print(parsed)
		print("Test 2.1.1 Passed!")

	########################################
	print("2.1.2 Invalid Account Id...")

	authority = authAuthorityUser1
	authorityAccountId = "44444444444444"
	authorityToken = authorityTokenUser1
	data = '{"authority":"'
	data = data + authority + '","authorityAccountId":"'
	data = data + authorityAccountId + '","authorityToken":"'
	data = data + authorityToken + '"}'

	print("Sending: " + str(data))

	response = http.request('POST', url, headers={'Content-Type':'application/json'}, body=data)

	responsebody = response.data.decode('utf-8')
	parsed = json.loads(responsebody)
	print("Token is not for this user expected...")
	if response.status != 400:
		print(parsed)
		print("Test 2.1.2 Failed")
		sys.exit(1)
	else:

		print(parsed)
		print("Test 2.1.2 Passed!")

	#############################################
	print("2.1.3 Invalid Authority Token")

	authority = authAuthorityUser1
	authorityAccountId = authorityAccountIdUser1
	authorityToken = "dfsdlkfjsd;faklsdjfsdl"
	data = '{"authority":"'
	data = data + authority + '","authorityAccountId":"'
	data = data + authorityAccountId + '","authorityToken":"'
	data = data + authorityToken + '"}'

	print("Sending: " + str(data))

	response = http.request('POST', url, headers={'Content-Type':'application/json'}, body=data)

	responsebody = response.data.decode('utf-8')
	parsed = json.loads(responsebody)

	print("HTTP 401 Unauthorized expected...")
	if response.status != 401:
		print(parsed)
		print("Test 2.1.3 Failed")
		sys.exit(1)
	else:
		print(parsed)
		print("Test 2.1.3 Passed!")

	##################################
	print("2.2 Successful Login")

	authority = authAuthorityUser1
	authorityAccountId = authorityAccountIdUser1
	authorityToken = authorityTokenUser1
	data = '{"authority":"'
	data = data + authority + '","authorityAccountId":"'
	data = data + authorityAccountId + '","authorityToken":"'
	data = data + authorityToken + '"}'

	print("Sending: " + str(data))

	response = http.request('POST', url, headers={'Content-Type':'application/json'}, body=data)

	responsebody = response.data.decode('utf-8')
	parsed = json.loads(responsebody)

	if response.status != 200:
		print(parsed)
		print("Test 2.2 Failed")
		sys.exit(1)
	else:
		print(parsed)
		parsed_login_responsebody = json.loads(responsebody)
		userSessionIdUser1 = parsed_login_responsebody["sessionId"]
		userIdUser1 = parsed_login_responsebody["userId"]
		print("SessionID: " + userSessionIdUser1)
		print("UserID: " + str(userIdUser1))
		print("Test 2.2 Passed!")


	authority = authAuthorityUser2
	authorityAccountId = authorityAccountIdUser2
	authorityToken = authorityTokenUser2
	data = '{"authority":"'
	data = data + authority + '","authorityAccountId":"'
	data = data + authorityAccountId + '","authorityToken":"'
	data = data + authorityToken + '"}'

	print("Sending: " + str(data))

	response = http.request('POST', url, headers={'Content-Type':'application/json'}, body=data)

	responsebody = response.data.decode('utf-8')
	parsed = json.loads(responsebody)

	if response.status != 200:
		print(parsed)
		print("Test 2.2 Failed")
		sys.exit(1)
	else:
		print(parsed)
		parsed_login_responsebody = json.loads(responsebody)
		userSessionIdUser1 = parsed_login_responsebody["sessionId"]
		userIdUser1 = parsed_login_responsebody["userId"]
		print("SessionID: " + userSessionIdUser1)
		print("UserID: " + str(userIdUser1))
		print("Test 2.2 Passed!")








	#


def test1():
	global authAuthorityUser1
	global authAuthorityUser2
	global authorityAccountIdUser1
	global authorityAccountIdUser2
	global authorityTokenUser1
	global authorityTokenUser2

	print("Test 1: Register new users")
	url = 'https://gethilingual.com/api/auth/register'
	data = '{"authority":"'
	data = data + authAuthorityUser1 + '","authorityAccountId":"'
	data = data + authorityAccountIdUser1 + '","authorityToken":"'
	data = data + authorityTokenUser1 + '"}'


	response = http.request('POST', url, headers={'Content-Type':'application/json'}, body=data)
	responsebody = response.data.decode("utf-8")
	if response.status != 200:
		print("Test failed")
		print(responsebody)
		sys.exit(1)
	else:
		parsed_login_responsebody = json.loads(responsebody)
		print(responsebody)
		userSessionIdUser1 = parsed_login_responsebody["sessionId"]
		userIdUser1 = parsed_login_responsebody["userId"]
		print("SessionID: " + userSessionIdUser1)
		print("UserID: " + str(userIdUser1))
		print("Test Passed For Test User 1!")


	data = '{"authority":"'
	data = data + authAuthorityUser2 + '","authorityAccountId":"'
	data = data + authorityAccountIdUser2 + '","authorityToken":"'
	data = data + authorityTokenUser2 + '"}'


	response = http.request('POST', url, headers={'Content-Type':'application/json'}, body=data)
	responsebody = response.data.decode("utf-8")
	if response.status != 200:
		print("Test failed")
		print(responsebody)
		sys.exit(1)
	else:
		parsed_login_responsebody = json.loads(responsebody)
		print(responsebody)
		userSessionIdUser2 = parsed_login_responsebody["sessionId"]
		userIdUser2 = parsed_login_responsebody["userId"]
		print("SessionID: " + userSessionIdUser2)
		print("UserID: " + str(userIdUser2))
		print("Test Passed For Test User 2!")
		print("Test 1 Passed!")






def main():
	global authAuthorityUser1
	global authAuthorityUser2
	global authorityAccountIdUser1
	global authorityAccountIdUser2
	global authorityTokenUser1
	global authorityTokenUser2

	testRegistration = input("Do you want to test registration?\n1)Yes\n2)No\n>")


	authAuthorityUser1  = input("What is the name of the authorization authority for user1:\n    1)Facebook\n    2)Google\n>")
	if authAuthorityUser1 == "1":
		authAuthorityUser1 = "FACEBOOK"
	elif authAuthorityUser1 == "2":
		authAuthorityUser1 = "GOOGLE"

	authorityAccountIdUser1 = input("Enter authority account id for user1:")
	authorityTokenUser1 = input("Enter authority token for user1:")

	authAuthorityUser2  = input("What is the name of the authorization authority for user2:\n    1)Facebook\n    2)Google\n>")
	if authAuthorityUser2 == "1":
		authAuthorityUser2 = "FACEBOOK"
	elif authAuthorityUser2 == "2":
		authAuthorityUser2 = "GOOGLE"

	authorityAccountIdUser2 = input("Enter authority account id for user2:")
	authorityTokenUser2 = input("Enter authority token for user2:")

	if testRegistration == "1":
		test1()

	test2()

	test3()

	test4()

	test5()

	test6()

	test7()


main()