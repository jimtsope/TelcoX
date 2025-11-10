# TelcoX

A telecom provider (TelcoX) wants to develop a relational database to monitor customers, calls and plans.
Customers of TelcoX are described through a unique identifier, first and last name, date of birth, gender (‘male’
or ‘female’) and live in a city. Cities are described by a unique identifier, name, population and mean income. A
customer has one or more contracts with TelcoX. A contract has a unique identifier, phone number, starting date,
ending date and a description. A contract is also associated to a plan offered by TelcoX (e.g. Red1 of Vodafone).
A plan is described by a unique identifier, name, free-minutes, free-sms and free-MB attributes. Finally, calls
made by a phone number have to be stored, along with a unique identifier, the date/time of the call (hour, minute,
day, month, year), the called phone number and the duration of the call (in seconds).
