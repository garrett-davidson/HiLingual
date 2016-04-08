#hilingual automated tests
#nateohlson



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

def test1():
	print("Test 1: Register new users")



def main():
	testRegistration = input("Do you want to test registration?\n1)Yes\n2)No\n>")

	if testRegistration == "1":
		test1()
		

	test2()

	test3()

	test4()

	test5()

	test6()

	test7()


main()