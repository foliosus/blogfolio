# Used to catch authorization failures, i.e. when someone attempts something they don't have rights to do
class NotAuthorized < StandardError
end