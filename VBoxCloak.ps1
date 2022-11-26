#################################################
## VBoxCloak.ps1: A script that attempts to hide the VirtualBox hypervisor from malware by modifying registry keys, killing associated processes, and removing uneeded driver/system files.
## Written and tested on Windows 7 System, but will likely work for Windows 10 as well.
## Many thanks to pafish for some of the ideas :) - https://github.com/a0rtega/pafish
##################################################
## Author: @d4rksystem (Kyle Cucci)
## Modified by Go Johansson - https://github.com/gojohansson/VBoxCloak
## Version: 0.5
##################################################

# Define command line parameters
param (
	[switch]$all = $false,
	[switch]$reg = $false,
	[switch]$procs = $false,
	[switch]$files = $false,
	[Switch]$name = $false
)

if ($all)
{
	$reg = $true
	$procs = $true
	$files = $true
	$name = $true
}

# Menu / Helper stuff
Write-Output 'VBoxCloak.ps1 by @d4rksystem (Kyle Cucci)'
Write-Output 'Usage: VBoxCloak.ps1 -<option>'
Write-Output 'Example Usage: VBoxCloak.ps1 -all'
Write-Output 'Options:'
Write-Output 'all: Enable all options.'
Write-Output 'reg: Make registry changes.'
Write-Output 'procs: Kill processes.'
Write-Output 'files: Make file system changes.'
Write-Output 'name: Randomize computer and account name.'
Write-Output 'Make sure to run as Admin!'
Write-Output '*****************************************'

# Define random string generator function
function Get-RandomString
{

	$charSet = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()

	for ($i = 0; $i -lt 10; $i++) {
		$randomString += $charSet | Get-Random
	}

	return $randomString
}

# Generate random vendor
function Get-RandomVendor {
	$vendors = 'HP', 'DELL', 'Lenovo', 'Alienware', 'ASUS'
	return Get-Random -InputObject $vendors
}

# Generate random models
function Get-RandomModel
{
	$models = 'ProBook 830', 'ThinkPad 430', 'Yoga 720'
	return Get-Random -InputObject $models
}

# Generate random BIOS vendors
function Get-RandomBIOSVendor
{
	$vendors = 'FOXCONN', 'American Megatrends', 'BYOSOFT'
	return Get-Random -InputObject $vendors
}

# Generate random BIOS release dates
function Get-RandomBIOSDate
{
	$dates = '2015/04/09', '2017/04/04', '2013/05/01', '2019/05/02'
	return Get-Random -InputObject $dates
}

# Generate random BIOS version
function Get-RandomBIOSVersion
{
	$versions = '1.01', '0.79', '3.1', '2.1'
	return Get-Random -InputObject $versions
}

# Generate random username
function Get-RandomUsername
{
	$names = 'Matthew', 'Ashley', 'Jennifer', 'Joshua', 'Amanda', 'Daniel', 'David', 'James', 'Robert', 'John', 'Joseph', 'Andrew', 'Ryan', 'Brandon', 'Jason', 'Justin', 'Sarah', 'William', 'Jonathan', 'Stephanie', 'Brian', 'Nicole', 'Nicholas', 'Anthony', 'Heather', 'Eric', 'Elizabeth', 'Adam', 'Megan', 'Melissa', 'Kevin', 'Steven', 'Thomas', 'Timothy', 'Christina', 'Kyle', 'Rachel', 'Laura', 'Lauren', 'Amber', 'Brittany', 'Danielle', 'Richard', 'Kimberly', 'Jeffrey', 'Amy', 'Crystal', 'Michelle', 'Tiffany', 'Jeremy', 'Benjamin', 'Mark', 'Emily', 'Aaron', 'Charles', 'Rebecca', 'Jacob', 'Stephen', 'Patrick', 'Sean', 'Erin', 'Zachary', 'Jamie', 'Kelly', 'Samantha', 'Nathan', 'Sara', 'Dustin', 'Paul', 'Angela', 'Tyler', 'Scott', 'Katherine', 'Andrea', 'Gregory', 'Erica', 'Mary', 'Travis', 'Lisa', 'Kenneth', 'Bryan', 'Lindsey', 'Kristen', 'Jose', 'Alexander', 'Jesse', 'Katie', 'Lindsay', 'Shannon', 'Vanessa', 'Courtney', 'Christine', 'Alicia', 'Cody', 'Allison', 'Bradley', 'Samuel', 'Shawn', 'April', 'Derek', 'Kathryn', 'Kristin', 'Chad', 'Jenna', 'Tara', 'Maria', 'Krystal', 'Jared', 'Anna', 'Edward', 'Julie', 'Peter', 'Holly', 'Marcus', 'Kristina', 'Natalie', 'Jordan', 'Victoria', 'Jacqueline', 'Corey', 'Keith', 'Monica', 'Juan', 'Donald', 'Cassandra', 'Meghan', 'Joel', 'Shane', 'Phillip', 'Patricia', 'Brett', 'Ronald', 'Catherine', 'George', 'Antonio', 'Cynthia', 'Stacy', 'Kathleen', 'Raymond', 'Carlos', 'Brandi', 'Douglas', 'Nathaniel', 'Ian', 'Craig', 'Brandy', 'Alex', 'Valerie', 'Veronica', 'Cory', 'Whitney', 'Gary', 'Derrick', 'Philip', 'Luis', 'Diana', 'Chelsea', 'Leslie', 'Caitlin', 'Leah', 'Natasha', 'Erika', 'Casey', 'Latoya', 'Erik', 'Dana', 'Victor', 'Brent', 'Dominique', 'Frank', 'Brittney', 'Evan', 'Gabriel', 'Julia', 'Candice', 'Karen', 'Melanie', 'Adrian', 'Stacey', 'Margaret', 'Sheena', 'Wesley', 'Vincent', 'Alexandra', 'Katrina', 'Bethany', 'Nichole', 'Larry', 'Jeffery', 'Curtis', 'Carrie', 'Todd', 'Blake', 'Christian', 'Randy', 'Dennis', 'Alison', 'Trevor', 'Seth', 'Kara', 'Joanna', 'Rachael', 'Luke', 'Felicia', 'Brooke', 'Austin', 'Candace', 'Jasmine', 'Jesus', 'Alan', 'Susan', 'Sandra', 'Tracy', 'Kayla', 'Nancy', 'Tina', 'Krystle', 'Russell', 'Jeremiah', 'Carl', 'Miguel', 'Tony', 'Alexis', 'Gina', 'Jillian', 'Pamela', 'Mitchell', 'Hannah', 'Renee', 'Denise', 'Molly', 'Jerry', 'Misty', 'Mario', 'Johnathan', 'Jaclyn', 'Brenda', 'Terry', 'Lacey', 'Shaun', 'Devin', 'Heidi', 'Troy', 'Lucas', 'Desiree', 'Jorge', 'Andre', 'Morgan', 'Drew', 'Sabrina', 'Miranda', 'Alyssa', 'Alisha', 'Teresa', 'Johnny', 'Meagan', 'Allen', 'Krista', 'Marc', 'Tabitha', 'Lance', 'Ricardo', 'Martin', 'Chase', 'Theresa', 'Melinda', 'Monique', 'Tanya', 'Linda', 'Kristopher', 'Bobby', 'Caleb', 'Ashlee', 'Kelli', 'Henry', 'Garrett', 'Mallory', 'Jill', 'Jonathon', 'Kristy', 'Anne', 'Francisco', 'Danny', 'Robin', 'Lee', 'Tamara', 'Manuel', 'Meredith', 'Colleen', 'Lawrence', 'Christy', 'Ricky', 'Randall', 'Marissa', 'Ross', 'Mathew', 'Jimmy', 'Abigail', 'Kendra', 'Carolyn', 'Billy', 'Deanna', 'Jenny', 'Jon', 'Albert', 'Taylor', 'Lori', 'Rebekah', 'Cameron', 'Ebony', 'Wendy', 'Angel', 'Micheal', 'Kristi', 'Caroline', 'Colin', 'Dawn', 'Kari', 'Clayton', 'Arthur', 'Roger', 'Roberto', 'Priscilla', 'Darren', 'Kelsey', 'Clinton', 'Walter', 'Louis', 'Barbara', 'Isaac', 'Cassie', 'Grant', 'Cristina', 'Tonya', 'Rodney', 'Bridget', 'Joe', 'Cindy', 'Oscar', 'Willie', 'Maurice', 'Jaime', 'Angelica', 'Sharon', 'Julian', 'Jack', 'Jay', 'Calvin', 'Marie', 'Hector', 'Kate', 'Adrienne', 'Tasha', 'Michele', 'Ana', 'Stefanie', 'Cara', 'Alejandro', 'Ruben', 'Gerald', 'Audrey', 'Kristine', 'Ann', 'Shana', 'Javier', 'Katelyn', 'Brianna', 'Bruce', 'Deborah', 'Claudia', 'Carla', 'Wayne', 'Roy', 'Virginia', 'Haley', 'Brendan', 'Janelle', 'Jacquelyn', 'Beth', 'Edwin', 'Dylan', 'Dominic', 'Latasha', 'Darrell', 'Geoffrey', 'Savannah', 'Reginald', 'Carly', 'Fernando', 'Ashleigh', 'Aimee', 'Regina', 'Mandy', 'Sergio', 'Rafael', 'Pedro', 'Janet', 'Kaitlin', 'Frederick', 'Cheryl', 'Autumn', 'Tyrone', 'Martha', 'Omar', 'Lydia', 'Jerome', 'Theodore', 'Abby', 'Neil', 'Shawna', 'Sierra', 'Nina', 'Tammy', 'Nikki', 'Terrance', 'Donna', 'Claire', 'Cole', 'Trisha', 'Bonnie', 'Diane', 'Summer', 'Carmen', 'Mayra', 'Jermaine', 'Eddie', 'Micah', 'Marvin', 'Levi', 'Emmanuel', 'Brad', 'Taryn', 'Toni', 'Jessie', 'Evelyn', 'Darryl', 'Ronnie', 'Joy', 'Adriana', 'Ruth', 'Mindy', 'Spencer', 'Noah', 'Raul', 'Suzanne', 'Sophia', 'Dale', 'Jodi', 'Christie', 'Raquel', 'Naomi', 'Kellie', 'Ernest', 'Jake', 'Grace', 'Tristan', 'Shanna', 'Hilary', 'Eduardo', 'Ivan', 'Hillary', 'Yolanda', 'Alberto', 'Andres', 'Olivia', 'Armando', 'Paula', 'Amelia', 'Sheila', 'Rosa', 'Robyn', 'Kurt', 'Dane', 'Glenn', 'Nicolas', 'Gloria', 'Eugene', 'Logan', 'Steve', 'Ramon', 'Bryce', 'Tommy', 'Preston', 'Keri', 'Devon', 'Alana', 'Marisa', 'Melody', 'Rose', 'Barry', 'Marco', 'Karl', 'Daisy', 'Leonard', 'Randi', 'Maggie', 'Charlotte', 'Emma', 'Terrence', 'Justine', 'Britney', 'Lacy', 'Jeanette', 'Francis', 'Tyson', 'Elise', 'Sylvia', 'Rachelle', 'Stanley', 'Debra', 'Brady', 'Charity', 'Hope', 'Melvin', 'Johanna', 'Karla', 'Jarrod', 'Charlene', 'Gabrielle', 'Cesar', 'Clifford', 'Byron', 'Terrell', 'Sonia', 'Julio', 'Stacie', 'Shelby', 'Shelly', 'Edgar', 'Roxanne', 'Dwayne', 'Kaitlyn', 'Kasey', 'Jocelyn', 'Alexandria', 'Harold', 'Esther', 'Kerri', 'Ellen', 'Abraham', 'Cedric', 'Carol', 'Katharine', 'Shauna', 'Frances', 'Antoine', 'Tabatha', 'Annie', 'Erick', 'Alissa', 'Sherry', 'Chelsey', 'Franklin', 'Branden', 'Helen', 'Traci', 'Lorenzo', 'Dean', 'Sonya', 'Briana', 'Angelina', 'Trista', 'Bianca', 'Leticia', 'Tia', 'Kristie', 'Stuart', 'Laurie', 'Harry', 'Leigh', 'Elisabeth', 'Alfredo', 'Aubrey', 'Ray', 'Arturo', 'Joey', 'Kelley', 'Max', 'Andy', 'Latisha', 'Johnathon', 'India', 'Eva', 'Ralph', 'Yvonne', 'Warren', 'Kirsten', 'Miriam', 'Kelvin', 'Lorena', 'Staci', 'Anita', 'Rene', 'Cortney', 'Orlando', 'Carissa', 'Jade', 'Camille', 'Leon', 'Paige', 'Marcos', 'Elena', 'Brianne', 'Dorothy', 'Marshall', 'Daryl', 'Colby', 'Terri', 'Gabriela', 'Brock', 'Gerardo', 'Jane', 'Nelson', 'Tamika', 'Alvin', 'Chasity', 'Trent', 'Jana', 'Enrique', 'Tracey', 'Antoinette', 'Jami', 'Earl', 'Gilbert', 'Damien', 'Janice', 'Christa', 'Tessa', 'Kirk', 'Yvette', 'Elijah', 'Howard', 'Elisa', 'Desmond', 'Clarence', 'Alfred', 'Darnell', 'Breanna', 'Kerry', 'Nickolas', 'Maureen', 'Karina', 'Roderick', 'Rochelle', 'Rhonda', 'Keisha', 'Irene', 'Ethan', 'Alice', 'Allyson', 'Hayley', 'Trenton', 'Beau', 'Elaine', 'Demetrius', 'Cecilia', 'Annette', 'Brandie', 'Katy', 'Tricia', 'Bernard', 'Wade', 'Chance', 'Bryant', 'Zachery', 'Clifton', 'Julianne', 'Angelo', 'Elyse', 'Lyndsey', 'Clarissa', 'Meaghan', 'Tanisha', 'Ernesto', 'Isaiah', 'Xavier', 'Clint', 'Jamal', 'Kathy', 'Salvador', 'Jena', 'Marisol', 'Darius', 'Guadalupe', 'Chris', 'Patrice', 'Jenifer', 'Lynn', 'Landon', 'Brenton', 'Sandy', 'Jasmin', 'Ariel', 'Sasha', 'Juanita', 'Israel', 'Ericka', 'Quentin', 'Jayme', 'Damon', 'Heath', 'Kira', 'Ruby', 'Rita', 'Tiara', 'Jackie', 'Jennie', 'Collin', 'Lakeisha', 'Kenny', 'Norman', 'Leanne', 'Hollie', 'Destiny', 'Shelley', 'Amie', 'Callie', 'Hunter', 'Duane', 'Sally', 'Serena', 'Lesley', 'Connie', 'Dallas', 'Simon', 'Neal', 'Laurel', 'Eileen', 'Lewis', 'Bobbie', 'Faith', 'Brittani', 'Shayla', 'Eli', 'Judith', 'Terence', 'Ciara', 'Charlie', 'Alyson', 'Vernon', 'Alma', 'Quinton', 'Nora', 'Lillian', 'Leroy', 'Joyce', 'Chrystal', 'Marquita', 'Lamar', 'Ashlie', 'Kent', 'Emanuel', 'Joanne', 'Gavin', 'Yesenia', 'Perry', 'Marilyn', 'Graham', 'Constance', 'Lena', 'Allan', 'Juliana', 'Jayson', 'Shari', 'Nadia', 'Tanner', 'Isabel', 'Becky', 'Rudy', 'Blair', 'Christen', 'Rosemary', 'Marlon', 'Glen', 'Genevieve', 'Damian', 'Michaela', 'Shayna', 'Marquis', 'Fredrick', 'Celeste', 'Bret', 'Betty', 'Kurtis', 'Rickey', 'Dwight', 'Rory', 'Mia', 'Josiah', 'Norma', 'Bridgette', 'Shirley', 'Sherri', 'Noelle', 'Chantel', 'Alisa', 'Zachariah', 'Jody', 'Christin', 'Julius', 'Gordon', 'Latonya', 'Lara', 'Lucy', 'Jarrett', 'Elisha', 'Deandre', 'Audra', 'Beverly', 'Felix', 'Alejandra', 'Nolan', 'Tiffani', 'Lonnie', 'Don', 'Darlene', 'Rodolfo', 'Terra', 'Sheri', 'Iris', 'Maxwell', 'Kendall', 'Ashly', 'Kendrick', 'Jean', 'Jarvis', 'Fred', 'Tierra', 'Abel', 'Pablo', 'Maribel', 'Donovan', 'Stephan', 'Judy', 'Elliott', 'Tyrell', 'Chanel', 'Miles', 'Fabian', 'Alfonso', 'Cierra', 'Mason', 'Larissa', 'Elliot', 'Brenna', 'Bradford', 'Kristal', 'Gustavo', 'Gretchen', 'Derick', 'Jarred', 'Pierre', 'Lloyd', 'Jolene', 'Marlene', 'Leo', 'Jamar', 'Dianna', 'Noel', 'Angie', 'Tatiana', 'Rick', 'Leann', 'Corinne', 'Sydney', 'Belinda', 'Lora', 'Mackenzie', 'Herbert', 'Guillermo', 'Tameka', 'Elias', 'Janine', 'Ben', 'Stefan', 'Josephine', 'Dominick', 'Jameson', 'Bobbi', 'Blanca', 'Josue', 'Esmeralda', 'Darin', 'Ashely', 'Clay', 'Cassidy', 'Roland', 'Ismael', 'Harrison', 'Lorraine', 'Owen', 'Daniela', 'Rocky', 'Marisela', 'Saul', 'Kory', 'Dexter', 'Chandra', 'Gwendolyn', 'Francesca', 'Alaina', 'Mandi', 'Fallon', 'Celia', 'Vivian', 'Rolando', 'Raven', 'Lionel', 'Carolina', 'Tania', 'Joann', 'Casandra', 'Betsy', 'Tracie', 'Dante', 'Trey', 'Margarita', 'Skyler', 'Sade', 'Lyndsay', 'Jacklyn', 'Marina', 'Rogelio', 'Racheal', 'Mollie', 'Liliana', 'Maegan', 'Felipe', 'Malcolm', 'Santana', 'Anastasia', 'Madeline', 'Breanne', 'Tiffanie', 'Dillon', 'Melisa', 'Darrin', 'Carlton', 'Cornelius', 'Precious', 'Ivy', 'Lea', 'Susana', 'Loren', 'Jeff'

	return Get-Random -InputObject $names
}

# Stop VBox Processes
if ($procs)
{

	Write-Output '[*] Attempting to kill VirtualBox processes (VBoxTray / VBoxService)...'

	$VBoxTray = Get-Process "VBoxTray" -ErrorAction SilentlyContinue

	if ($VBoxTray)
	{
		$VBoxTray | Stop-Process -Force
		Write-Output '[*] VBoxTray process killed!'
	}

	if (!$VBoxTray)
	{
		Write-Output '[!] VBoxTray process does not exist!'
	}

	$VBoxService = Get-Process "VBoxService" -ErrorAction SilentlyContinue

	if ($VBoxService)
	{
		$VBoxService | Stop-Process -Force
		Write-Output '[*] VBoxService process killed!'
	}

	if (!$VBoxService)
	{
		Write-Output '[!] VBoxService process does not exist!'
	}
}

# Modify Computer and Account name

if ($name)
{
	$ComputerName = "$( Get-RandomString )-PC"

	Remove-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "Hostname"
	Remove-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "NV Hostname"

	Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Computername\Computername" -name "Computername" -value $ComputerName
	Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Computername\ActiveComputername" -name "Computername" -value $ComputerName
	Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "Hostname" -value $ComputerName
	Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "NV Hostname" -value  $ComputerName
	Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name "AltDefaultDomainName" -value $ComputerName
	Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name "DefaultDomainName" -value $ComputerName

}

# Modify VBox registry keys
if ($reg)
{

	# Modify system BIOS version

	if (Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "SystemBiosVersion" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Modifying Reg Key HKLM:\HARDWARE\Description\System\SystemBiosVersion..."
		Set-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "SystemBiosVersion" -Value $( Get-RandomString )

	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\HARDWARE\Description\System\SystemBiosVersion does not seem to exist! Skipping this one...'
	}

	# Modify CurrentControlSet BIOS info

	if (Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Modifying Reg Key Values in HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation..."
		Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "BIOSVersion" -Value $( Get-RandomBIOSVersion )
		Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "BIOSReleaseDate" -Value $( Get-RandomBIOSDate )
		Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "BIOSProductName" -Value $( Get-RandomBIOSVendor )
		Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "SystemManufacturer" -Value $( Get-RandomVendor )
		Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "SystemProductName" -Value $( Get-RandomModel )
	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation does not seem to exist! Skipping this one...'
	}

	# Modify system BIOS date

	if (Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "SystemBiosDate" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Modifying Reg Key HKLM:\HARDWARE\Description\System\SystemBiosDate"
		Set-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "SystemBiosDate" -Value $( Get-RandomString )

	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\HARDWARE\Description\System\SystemBiosDate does not seem to exist! Skipping this one...'
	}

	# Modify system BIOS Video Version

	if (Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "VideoBiosVersion" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Modifying Reg Key HKLM:\HARDWARE\Description\System\VideoBiosVersion"
		Set-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "VideoBiosVersion" -Value $( Get-RandomString )

	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\HARDWARE\Description\System\VideoBiosVersion does not seem to exist! Skipping this one...'
	}

	# Rename Guest Additions Reg Key

	if (Get-Item -Path "HKLM:\SOFTWARE\Oracle\VirtualBox Guest Additions" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Renaming Reg Key HKLM:\SOFTWARE\Oracle\VirtualBox Guest Additions"
		Rename-Item -Path "HKLM:\SOFTWARE\Oracle\VirtualBox Guest Additions" -NewName $( Get-RandomString )

	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\SOFTWARE\Oracle\VirtualBox Guest Additions does not seem to exist, or has already been renamed! Skipping this one...'
	}

	# Rename ACPI DSDT Reg Key

	if (Get-Item -Path "HKLM:\HARDWARE\ACPI\DSDT\VBOX__" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Renaming Reg Key HKLM:\HARDWARE\ACPI\DSDT\VBOX__"
		Rename-Item -Path "HKLM:\HARDWARE\ACPI\DSDT\VBOX__" -NewName $( Get-RandomString )

	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\HARDWARE\ACPI\DSDT\VBOX__ does not seem to exist, or has already been renamed! Skipping this one...'
	}

	# Rename ACPI FADT Reg Key

	if (Get-Item -Path "HKLM:\HARDWARE\ACPI\FADT\VBOX__" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Renaming Reg Key HKLM:\HARDWARE\ACPI\FADT\VBOX__"
		Rename-Item -Path "HKLM:\HARDWARE\ACPI\FADT\VBOX__" -NewName $( Get-RandomString )

	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\HARDWARE\ACPI\FADT\VBOX__ does not seem to exist, or has already been renamed! Skipping this one...'
	}

	# Rename ACPI RSDT Reg Key

	if (Get-Item -Path "HKLM:\HARDWARE\ACPI\RSDT\VBOX__" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Renaming Reg Key HKLM:\HARDWARE\ACPI\RSDT\VBOX__"
		Rename-Item -Path "HKLM:\HARDWARE\ACPI\RSDT\VBOX__" -NewName $( Get-RandomString )

	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\HARDWARE\ACPI\RSDT\VBOX__ does not seem to exist, or has already been renamed! Skipping this one...'
	}

	# Rename VBoxMouse Reg Key

	if (Get-Item -Path "HKLM:\SYSTEM\ControlSet001\services\VBoxMouse" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Renaming Reg Key HKLM:\SYSTEM\ControlSet001\services\VBoxMouse"
		Rename-Item -Path "HKLM:\SYSTEM\ControlSet001\services\VBoxMouse" -NewName $( Get-RandomString )

	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\SYSTEM\ControlSet001\services\VBoxMouse does not seem to exist, or has already been renamed! Skipping this one...'
	}

	# Rename VBoxService Reg Key

	if (Get-Item -Path "HKLM:\SYSTEM\ControlSet001\services\VBoxService" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Renaming Reg Key HKLM:\SYSTEM\ControlSet001\services\VBoxService"
		Rename-Item -Path "HKLM:\SYSTEM\ControlSet001\services\VBoxService" -NewName $( Get-RandomString )

	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\SYSTEM\ControlSet001\services\VBoxService does not seem to exist, or has already been renamed! Skipping this one...'
	}

	# Rename VBoxSF Reg Key

	if (Get-Item -Path "HKLM:\SYSTEM\ControlSet001\services\VBoxSF" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Renaming Reg Key HKLM:\SYSTEM\ControlSet001\services\VBoxSF"
		Write-Output "[!] Warning: This will disconnect VM shared folders. You will need to reconnect them later..."
		Rename-Item -Path "HKLM:\SYSTEM\ControlSet001\services\VBoxSF" -NewName $( Get-RandomString )

	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\SYSTEM\ControlSet001\services\VBoxSF does not seem to exist, or has already been renamed! Skipping this one...'
	}

	# Rename VBoxVideo Reg Key

	if (Get-Item -Path "HKLM:\SYSTEM\ControlSet001\services\VBoxVideo" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Renaming Reg Key HKLM:\SYSTEM\ControlSet001\services\VBoxVideo"
		Rename-Item -Path "HKLM:\SYSTEM\ControlSet001\services\VBoxVideo" -NewName $( Get-RandomString )

	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\SYSTEM\ControlSet001\services\VBoxVideo does not seem to exist, or has already been renamed! Skipping this one...'
	}

	# Rename VBoxGuest Reg Key

	if (Get-Item -Path "HKLM:\SYSTEM\ControlSet001\services\VBoxGuest" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Renaming Reg Key HKLM:\SYSTEM\ControlSet001\services\VBoxGuest"
		Rename-Item -Path "HKLM:\SYSTEM\ControlSet001\services\VBoxGuest" -NewName $( Get-RandomString )

	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\SYSTEM\ControlSet001\services\VBoxGuest does not seem to exist, or has already been renamed! Skipping this one...'
	}

	# Rename VBoxTray Reg Key

	if (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "VBoxTray" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Renaming Reg Key HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\VBoxTray"
		Rename-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "VBoxTray" -NewName $( Get-RandomString )

	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\VBoxTray does not seem to exist, or has already been renamed! Skipping this one...'
	}

	# Rename VBox Uninstaller Reg Key

	if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Oracle VM VirtualBox Guest Additions" -ErrorAction SilentlyContinue)
	{

		Write-Output "[*] Renaming Reg Key HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Oracle VM VirtualBox Guest Additions"
		Rename-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Oracle VM VirtualBox Guest Additions" -NewName $( Get-RandomString )

	}
	Else
	{

		Write-Output '[!] Reg Key HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Oracle VM VirtualBox Guest Additions does not seem to exist, or has already been renamed! Skipping this one...'
	}
}

# Remove VBox Driver Files
if ($files)
{

	Write-Output '[*] Attempting to remove VirtualBox driver files...'

	$vboxFiles1 = "C:\Windows\System32\drivers\VBox*"

	if ($vboxFiles1)
	{
		Remove-Item $vboxFiles1
	}

	# Remove VBox system32 files

	Write-Output '[*] Attempting to remove VirtualBox system32 files...'

	$vboxFiles2 = "C:\Windows\System32\VBox*"
	Remove-Item $vboxFiles2 -EV Err -ErrorAction SilentlyContinue

	# Rename VBoxMRXNP DLL file
	# We have to rename this file because we get errors when attempting to delete it! :o

	Write-Output '[*] Attempting to rename VBoxMRXNP.dll file...'
	Rename-Item "C:\Windows\System32\VBoxMRXNP.dll" "C:\Windows\System32\$( Get-RandomString ).dll"

	# Rename VirtualBox folder path

	Write-Output '[*] Attempting to rename VirtualBox folder path...'
	Rename-Item "C:\Program Files\Oracle\VirtualBox Guest Additions" "C:\Program Files\Oracle\$( Get-RandomString )"
}

Write-Output '** Done! Did you recieve a lot of errors? Try running as Admin!'
