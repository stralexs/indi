# indi

<p align="center">
An English learning app
</p>

![Screenshot 2023-06-06 at 21 18 31](https://github.com/stralexs/indi/assets/123239625/87984af6-f795-48fc-8889-1d6aeee826a7)

## Concept
### Problem: how to make a person with 0-level English knowledge a native speaker?
"indi" is an application that will allow the user to "grow up" as a native speaker. The application offers a new approach to learning a foreign language, which relies on the formation of speech and intellect of a native speaker according to the stages of human life: from infancy to maturity.

![Screenshot 2023-06-06 at 21 18 31](https://github.com/stralexs/indi/assets/123239625/c20552ef-fb5a-4574-b127-1c58c374991f)

## Gameplay

![ds](https://github.com/stralexs/indi/assets/123239625/d40efe6c-32d0-4f52-8355-0a47309db25b)

### General hierarchy of Study stages
User goes through the levels of learning the language, starting with the simplest, ending with more and more complex:
*1. Newborn stage*
*2. Preschool stage*
*3. Early school stage*
*4. High school + Life activities stage*
And on the last stage User can choose what to learn, as well as any native speaker can choose what univerity one can attend. User has these options:
*Programming university*
*Construction university*
*Side jobs*
### Main story gameplay
User learns words in a form of tests. Each Study stage has kits of different words to learn. Each question has 4 different buttons with answers, which User has to choose which to answer.
To proceed further User has to have a result of each kit above 70%. If so, access to the exam is then opened, where the user answers 10 random questions from the same word kits, but now he must write the answer himself in TextField.
When the result of an exam is equal or above 50%, next Study stage is opened.
### Workout mode
In workout mode, User can skip story mode and simply select the sets that he wants to learn and the number of words to learn. In essence, this is the same test, however, the user will be constantly prompted to try again to answer all incorrectly answered questions.
### Settings
User can change his name and avatar. Also can reset all his achievements.
### New kit
In this section, User creates his own set of words: writes the name, selects the stage of study and then adds questions. In addition, User can delete previously added sets by long pressing on it on the kit selection screen or in workout mode.
### Statistics
here the user is shown all his statistics: what percentage of each set was studied, what percentage the exam was passed and general statistics.
### Network
Here, the situation is played out when a json with a kit comes from the server: the application sends a request, parses json, displays result to User and offers to add it to the study stage he likes.

## Structure of an app
### Navigation
To navigate between View Controllers a Navigation Controller is used.
### Testing protocol
All possible options for learning words: testing, exam and workout are conforming to Testing protocol, that describes a set of methods for Models of these ways of learning.
```
protocol Testing {
    var userAnswer: String? { get set }
    func testStart()
    func test(questionLabel UILabel: UILabel?, buttons UIButtons: [UIButton]?, countLabel UILabel: UILabel?)
    func isRightAnswerCheck() -> Bool
    func nextQuestion()
    func resetResults()
}
```
### Custom types
All data with kits and questions in "indi" is stored in Core Data in a form of Entities and its attributesd and relationships, but for a more visual representation, here I will write them as structures:
```
struct Question {
    var question: String?
    var correctAnswer: String?
    var incorrectAnswers: [String]?
}

struct Kit {
    var name: String?
    var studyStage: Int64?
    var questions: [Question]? 
}
```
You might notice that variable studyStage has a raw value of Int64, even though it's an enumeration that uses cases of type String:
```
enum StudyStage: Int64  {
    case newborn
    case preschool
    case earlySchool
    case highSchool
    case lifeActivities
    case programmingUniversity
    case constructionUniversity
    case sideJob
}
```
Integer is used because it is the most convenient way to pass information between controllers: almost all UI elements, such as Buttons and TableViews, have a tag property.
As an example: several buttons are bound to the same IBAction, and when pressed, the button tag corresponding to the raw value of its study stage is passed to the next View Controller.
Int64 is used due to requirements of Core Data.
### User data
User's achievements is stored in User Defaults, this is done by a special class UserData.
### Architecture

![structure](https://github.com/stralexs/indi/assets/123239625/43846665-ca87-4f6d-bb82-2dc4e28518a5)

Currently arhictecture of an app is MVC, even though it might look that it's MVVM at a first glance.
All classes somehow refer to two Singleton objects: KitsLibrary and UserData, that manage all the info in the app. Singleton is a good choice in this situation, since we won't need child classes and singleton objects don't idle because *all* application classes interact with them.
What makes this drawing not MVVM? Well, View Controllers know about the Model: they interact with it when they ask, for example, the number of Kits for a TableView.
For now it's working, however, I will soon revise the architecture and make it a pure MVVM, as it fits right in here.
### Working with User's achievements
To save User's progress, once User reaches the required score on a test or exam, the respective exam buttons are assigned a Reuse Identifier "Completed", that is stored in UserData class. This ensures that the walkthrough will not fail, even if User decides to add additional Kits of words to already completed Study stages.
As soon as access to the next Study stage opens, all Buttons and lines are no longer translucent: their alpha equals 1.
## Stack
- Swift
- UIKit
- MVC
- Singleton
- Storyboard, autolayout
- URLSession
- GCD
## Well, that's it, folks! Have a great day and learn English :)


