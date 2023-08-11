# indi

<p align="center">
An English learning app
</p>

![1](https://github.com/stralexs/indi/assets/123239625/651ecc98-f3d3-412a-b7b6-d04e21649513)

![2](https://github.com/stralexs/indi/assets/123239625/6ff435ed-769b-4690-a639-5b35ecb15611)

## Concept
### Problem: how to make a person with 0-level English knowledge a native speaker?
"indi" is an application that will allow the user to "grow up" as a native speaker. The application offers a new approach to learning a foreign language, which relies on the formation of speech and intellect of a native speaker according to the stages of human life: from infancy to maturity.

![Screenshot 2023-06-06 at 21 18 31](https://github.com/stralexs/indi/assets/123239625/c20552ef-fb5a-4574-b127-1c58c374991f)

## Gameplay

![General overlook](https://github.com/stralexs/indi/assets/123239625/b1f25e0a-8c13-45fb-b470-e30ed1beea34)
<p align="center">
General app overlook
</p>

"indi" app allows user to learn words in 2 ways:
- *Story mode*
- *Training mode*

and also add custom words Kits that User can create himself or download from the Internet.
Access to these modes is achieved through implementation of the TabBar at the bottom of the screen.

## Story Mode
Learing of words is carried out in the form of tests with four answers, followed by a check of knowledge in the form of an exam. User moves from the simplest words Kits to more complex ones, thereby repeating the life path of a native speaker.

### General hierarchy of Study stages
At first, the learning of words is linear, User moves from child's word Kits to school ones:
- *1. Newborn stage*
- *2. Preschool stage*
- *3. Early school stage*
- *4. High school + Life activities stage*

And on the last stage User can choose what to learn, as well as any native speaker can choose what univerity or job one can attend. User has these options:
- *Programming university*
- *Construction university*
- *Side jobs*

![StudyStage tree](https://github.com/stralexs/indi/assets/123239625/93478094-089a-4bd2-8fc3-12efee07d2b2)
<p align="center">
Study stages learning tree and the last stage Variability
</p>
In order to advance further, User must score at least 70% on each words Kit of the current Study stage. After this condition is met, access to the Exam is opened, in which User must score at least 50% in order to open access to the next Study stage. User cannot learn inaccessible words Kits (an alert will be shown). As soon as access to the next Study stage opens, all Buttons and lines are no longer translucent: their alpha equals 1. Study stages are accessed by setting button's restoration identifiers values of "Completed" or "Uncompleted". In addition, it does not allow blocking the walkthrough if User adds his own custom Kit to the already opened and completed Study stage. In the last stage with Variability, the buttons' restoration identifiers are also assigned values of "Selected" or "Unselected" indicating whether User has selected that Study stage.

### Testing

![Testing](https://github.com/stralexs/indi/assets/123239625/31f6638a-3f14-41bf-87b9-3623080402db)

When User selects the Study stage on the Story Mode screen, the Kit Selection screen is shown to User. Here, in the form of a vertically oriented CollectionView, Kits are located: each has a name, result of User in the upper right corner, while the background is filled with a more saturated color depending on the result of the Test.
The Test itself is a question with four buttons with answer options. WhenUser answers correctly, a green check mark is shown, when answers incorrectly, a red cross is shown (as well as sounds). Upon completion, User is shown an alert with the result.

### Exam

![Exam](https://github.com/stralexs/indi/assets/123239625/348c7a73-0d65-4619-a4d6-cdeae9322d2c)

Exam consists of 10 random questions from the completed words Kits, but now User must confirm his knowledge by answering essentially the same questions, but enter the answers into the TextField on their own. Any hints and auto-correction of the keyboard are disabled.

### Settings and Statistics
![SettingsAndStatistics](https://github.com/stralexs/indi/assets/123239625/734471a8-e546-45ee-8209-01cadddef547)

At the top of the Story Mode screen there is a button that leads to the Settings and Statistics screen. Here User can view his general statistics, change his avatar and name.

![Deleting User achievements](https://github.com/stralexs/indi/assets/123239625/c1a9ab75-cfa1-4370-9834-1b846450f046)

In addition, there is also a Switch that resets all User's achievements. Before the changes are applied, User is additionally notified that the action is irreversible.

## Training Mode
![Training](https://github.com/stralexs/indi/assets/123239625/7138c959-ea47-48ca-bbd7-87023b4b777b)

In case User doesn't want to learn words in the Story Mode, and the walkthrough does not allow him to learn the Kits that he needs, he can select the Training Mode. Here, in the form of a TableView, all the same words Kits are presented, but access to them is already granted. Here User selects Kits with a check mark, and then with a Slider chooses the number of words from the selected Kits, where the maximum is the sum of the words of all selected Kits. In fact, Training Mode is similar to Testing, but with a significant difference: at the top of the screen there is a Progress View that fills in as User answers correctly. Upon completion, User will be asked to complete the incorrectly answered words. The Progress View will be completely filled when User answers correctly to all the initially selected words.

## New Kit
When User presses the middle button on the Tab Bar, he is modally presented a screen with 2 options: create your own words Kit, or download it from the Internet.
In fact, both options are almost identical both on the screen and under the hood, so it was decided to make the parent View Controller and View Model, and both options will inherit all the common functionality from the parents, supplementing with their own.
<img width="1027" alt="3" src="https://github.com/stralexs/indi/assets/123239625/645d64b9-d935-439f-a831-295e4263faaa">
<p align="center">
New Kit Inheritance
</p>

### User New Kit
![User New Kit](https://github.com/stralexs/indi/assets/123239625/fc1351c6-ca75-4b7a-9244-8e6bc95a2a56)

On the User Kit creation screen, User enters a name for the new Kit, selects Study stage, and then enters questions for Kit via an AlertController with TextFields. Alert has restrictions, for example, incorrect answers cannot contain the correct answer. In addition, User is not required to enter all 3 incorrect answers. When User adds a Kit, it appears in the selected Study stage. Also, User can delete the added Kit by long pressing (basic Kits cannot be deleted).

### Network New Kit
![Network New Kit](https://github.com/stralexs/indi/assets/123239625/5c855920-0f09-40de-a524-786a99809e96)

When creating a Kit via the Internet, the process is identical, but now the words Kit is loaded using the theoretical response from the server (the json is stored on jsonbin website).

![No Internet](https://github.com/stralexs/indi/assets/123239625/7ba9fd09-9227-4388-bb38-ce3e0b1b2bc3)

The application also handles the situation when User has no Internet connection using NWPathMonitor: User is shown an alert with a classic dinosaur.

## Structure of an app
### Data
All data with Kits and questions in "indi" is stored in Core Data in a form of Entities and its attributesd and relationships, but for a more visual representation, here I will write them as structures:
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
KitsManger class is responsible for fetching data, creating Kits and working with Core Data.
User's achievements are stored in User Defaults and UserDataManager class is responsible for storing, saving and deleting User data.

### Architecture
![4](https://github.com/stralexs/indi/assets/123239625/a552ba60-d3d0-41b5-b91c-e25d1cdb2944)
<p ![Uploading 4.jpg…]()
align="center">
App's MVVM Architecture
</p>
Architecture of the application is MVVM: each View Controller has a View Model, that interacts with KitsManger and UserDataManager classes, that are responsible for processing of data.
Some ViewModels also interact with other managers, for instance NetworkViewModel interacts with NetworkManager, when a request to the server is made, and TestingViewModel interacts with SoundManager, when a correct or wrong answer sound should be played.
Protocols are used all around the app to reduce coupling between modules. ViewModels inject dependency to ViewControllers through special functions that initialize an instance of a certain protocol, for example:

```
func viewModelForSettingAndStatistics() -> SettingsAndStatisticsViewModelProtocol? {
    return SettingsAndStatisticsViewModel()
}
```

The singleton pattern is used for UserDataManager and KitsManager because almost all ViewModels need access to them. These classes themselves are quite large and constantly initializing them with dependency injection rather than doing it once with a start of an app will cost performance (confirmed).

### Study stage enumeration
To determine which Study stage a words Kit belongs to, enumeration StudyStage is used:
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
You might notice that studyStage has a raw value of Int64. Integer is used because it is the most convenient way to pass information between Controllers and Models: almost all UI elements, such as Buttons and TableViews, have a tag property.
As an example: several buttons are bound to the same IBAction, and when pressed, the button tag corresponding to the raw value of its Study stage is passed to the next View Controller's View Model.
Int64 is used due to requirements of Core Data.

## Stack
- Swift
- UIKit
- MVVM
- Dependency Injection, Inheritance, Singleton
- Observable Objects
- Notification Center
- Storyboard, Autolayout
- URLSession
- GCD
- Core Data, User Defaults

![5](https://github.com/stralexs/indi/assets/123239625/06fb4eb1-bee6-4bb5-8b4a-a4323c11d6d9)

## Well, that's it, folks! Have a great day and learn English :)
