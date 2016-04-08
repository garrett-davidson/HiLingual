#hilingual automated tests
#nateohlson

import sys
import json



def test7():
	print("Test 7: Recieve Message")

def test6():
	print("Test 6: Send Message")


def test5():
	print("Test 5: Accept Chat")


def test4():
	print("Test 4: Request Chat")

def test3():
	print("Test 3: Search Users")


def test2():
	print("Test 2: Change Profile Info")

	#


def test1():
	print("Test 1: Register new users")
	url = 'https://gethilingual.com/api/auth/register'
	data = '{"authority":"'
	data = data + authority + '","authorityAccountId":"'
	data = data + authorityAccountId + '","authorityToken":"'
	data = data + authorityToken + '"}'


	response = http.request('POST', url, headers={'Content-Type':'application/json'}, body=data)
	responsebody = response.data.decode("utf-8")
	if response.status != 200:
		print("Test failed")
		print(responsebody)
		sys.exit(1)
	else:
		parsed_login_responsebody = json.loads(responsebody)
		print(responsebody)
		userSessionId = parsed_login_responsebody["sessionId"]
		userId = parsed_login_responsebody["userId"]
		print("SessionID: " + userSessionId)
		print("UserID: " + str(userId))
		print("Test Passed!")





def main():
	global authAthorityUser1
	global authAthorityUser2
	global authorityAccountIdUser1
	global authorityAccountIdUser2

	testRegistration = input("Do you want to test registration?\n1)Yes\n2)No\n>")


	authAthorityUser1  = input("What is the name of the authorization authority for user1:\n    1)Facebook\n    2)Google\n>")
	if authAthorityUser1 == "1":
		authAthorityUser1 = "FACEBOOK"
	elif authAthorityUser1 == "2":
		authAthorityUser1 = "GOOGLE"

	authAthorityUser2  = input("What is the name of the authorization authority for user2:\n    1)Facebook\n    2)Google\n>")
	if authAthorityUser2 == "1":
		authAthorityUser2 = "FACEBOOK"
	elif authAthorityUser2 == "2":
		authAthorityUser2 = "GOOGLE"

	authorityAccountIdUser1 = input("Enter authority account id for user1:")
	authorityTokenUser1 = input("Enter authority token for user1:")

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