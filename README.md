# indi

<p align="center">
An English learning app
</p>

![Screenshot 2023-06-06 at 21 18 31](https://github.com/stralexs/indi/assets/123239625/87984af6-f795-48fc-8889-1d6aeee826a7)

## Concept
### Problem: how to make a person with 0-level English knowledge a native speaker?
"indi" is an application that will allow the user to "grow up" as a native speaker. The application offers a new approach to learning a foreign language, which relies on the formation of speech
and intellect of a native speaker according to the stages of human life: from infancy to maturity.

![Screenshot 2023-06-06 at 21 18 31](https://github.com/stralexs/indi/assets/123239625/c20552ef-fb5a-4574-b127-1c58c374991f)

## Gameplay
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

![ds](https://github.com/stralexs/indi/assets/123239625/d40efe6c-32d0-4f52-8355-0a47309db25b)

## Structure of an app
### Navigation
To navigate between View Controllers a Navigation Cobtroller is implemented.
### Testing protocol
All possible options for learning words: testing, exam and workout are conforming to Testing protocol, that describes a set of functions for usual test.
''''
protocol Testing {
    var userAnswer: String? { get set }
    
    func testStart()
    func test(questionLabel UILabel: UILabel?, buttons UIButtons: [UIButton]?, countLabel UILabel: UILabel?)
    func isRightAnswerCheck() -> Bool
    func nextQuestion()
    func resetResults()
}
