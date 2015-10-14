# Add a checkbox for an eating class
addCheckbox = (name) ->
  elem = $("
    <div class='item'>
      <div class='ui checkbox'>
        <input name='#{name}' type='checkbox' class='ec' id='ec-#{name}'>
        <label>#{name}</label>
      </div>
    </div>
    ")
  $("div#eatingClasses").append(elem)

# A food. Keeps track of which eating classes disallow it and handles changes
# in allowance
class Food
  constructor: (@name, @forbiddenIn...) ->
    @allowed = true

  # Check if this food is forbidden when using an eating class
  forbidden: (ec) ->
    return ec in @forbiddenIn

  # Remove this food from the list of allowed ones
  forbid: ->
    @allowed = false
    $("div#forbidden").append($("div#food-#{@name}"))

  # Add this food to the list of allowed ones
  allow: ->
    @allowed = true
    $("div#allowed").append($("div#food-#{@name}"))

  # Change the food status to whatever it is not right now aka toggle it
  toggle: ->
    if @allowed then @forbid() else @allow()

  # Check if the current status is correct and take action if not
  check: (ecs) ->
    newStatus = (@forbidden(ec) for ec in ecs)
    if true in newStatus and @allowed
      @forbid()
    else if true not in newStatus and not @allowed
      @allow()

# Add all the foods to the left column. For initial setup only. Returns the
# Food object for registering it in the global list
addFood = (food) ->
  elem = $("<div class='item' id='food-#{food.name}'>#{food.name}</div>")
  $("div#allowed").append(elem)
  return new Food [food.name].concat(food.forbidden)...

# Run this as soon as the page is loaded
jQuery ->

  # List the different classes that a person can be part of and add a checkbox
  # for each one
  eatingClasses = [ "Fruitarianism", "Gluten-free", "Hinduism", "Islam",
                    "Judaism", "Mormonism", "Pescetarianism", "Veganism",
                    "Vegetarianism" ]
  addCheckbox(ec) for ec in eatingClasses

  forbiddenClasses = []

  # List the different foods for adding them easily
  foods = [
    {name: "Pork",      forbidden: ["Fruitarianism, Judaism", "Islam",
                                    "Veganism", "Vegetarianism",
                                    "Pescetarianism"]},
    {name: "Fish",      forbidden: ["Fruitarianism", "Veganism",
                                    "Vegetarianism"]},
    {name: "Milk",      forbidden: ["Fruitarianism", "Veganism"]},
    {name: "Cheese",    forbidden: ["Fruitarianism", "Veganism"]},
    {name: "Shellfish", forbidden: ["Fruitarianism", "Veganism",
                                    "Vegetarianism"]},
    {name: "Alcohol",   forbidden: ["Islam"]} ]
  allFoods = (addFood(f) for f in foods)

  # Change the allowed classes, trigger new checks for the food
  $("input.ec").click(->
    className = $(@).prop("name")
    if $(@).prop("checked")
      forbiddenClasses.push(className)
    else
      forbiddenClasses = (ec for ec in forbiddenClasses when ec != className)
    f.check(forbiddenClasses) for f in allFoods
    )

