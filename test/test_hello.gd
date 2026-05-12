extends GdUnitTestSuite
#part 1: setup the test
#part 2: execute the test
#part 3: determine if test was successful
#NOTES - script must be in test folder and its name should be test_x, add extends GDUnitTestSuite too!
func test_hello():
	#given that I have to variables,
	var a:int = 5
	var b:int = 10
	
	#if I take minimum of two variables
	var result:int = min(a, b)
	
	#the result I have is the smaller of the two
	assert_int(result).is_equal(b)
	
	
	
