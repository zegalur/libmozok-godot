#include "gdmozok.hpp"

#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include <memory>

using namespace godot;


// ================================= FORMATS ================================ //


// ================================ BINDINGS ================================ //

namespace {

const auto ON_ACTION_ERROR_SIGNAL = "action_error";
const auto ON_ACTION_PUSHED_SIGNAL = "action_pushed";
const auto ON_NEW_MAIN_QUEST_SIGNAL = "new_main_quest";
const auto ON_NEW_SUB_QUEST_SIGNAL = "new_sub_quest";
const auto ON_NEW_QUEST_STATE_SIGNAL = "new_quest_state";
const auto ON_NEW_QUEST_STATUS_SIGNAL = "new_quest_status";
const auto ON_NEW_QUEST_GOAL_SIGNAL = "new_quest_goal";
const auto ON_NEW_QUEST_PLAN_SIGNAL = "new_quest_plan";
const auto ON_SEARCH_LIMIT_REACHED_SIGNAL = "search_limit_reached";
const auto ON_SPACE_LIMIT_REACHED_SIGNAL = "space_limit_reached";

const auto ACTION_APPLICABLE = mozok::Server::ACTION_APPLICABLE;
const auto ACTION_NOT_APPLICABLE = mozok::Server::ACTION_NOT_APPLICABLE;
const auto ACTION_UNDEFINED = mozok::Server::ACTION_UNDEFINED;

const auto QUEST_STATUS_INACTIVE = mozok::QuestStatus::MOZOK_QUEST_STATUS_INACTIVE;
const auto QUEST_STATUS_DONE = mozok::QuestStatus::MOZOK_QUEST_STATUS_DONE;
const auto QUEST_STATUS_REACHABLE = mozok::QuestStatus::MOZOK_QUEST_STATUS_REACHABLE;
const auto QUEST_STATUS_UNREACHABLE = mozok::QuestStatus::MOZOK_QUEST_STATUS_UNREACHABLE;
const auto QUEST_STATUS_UNKNOWN = mozok::QuestStatus::MOZOK_QUEST_STATUS_UNKNOWN;

const auto ACTION_ERROR_NO_ERROR = mozok::ActionError::MOZOK_AE_NO_ERROR;
const auto ACTION_ERROR_UNDEFINED_ACTION = mozok::ActionError::MOZOK_AE_UNDEFINED_ACTION;
const auto ACTION_ERROR_ARITY_ERROR = mozok::ActionError::MOZOK_AE_ARITY_ERROR;
const auto ACTION_ERROR_UNDEFINED_OBJECT = mozok::ActionError::MOZOK_AE_UNDEFINED_OBJECT;
const auto ACTION_ERROR_TYPE_ERROR = mozok::ActionError::MOZOK_AE_TYPE_ERROR;
const auto ACTION_ERROR_PRECONDITIONS_ERROR = mozok::ActionError::MOZOK_AE_PRECONDITIONS_ERROR;
const auto ACTION_ERROR_NA_ACTION = mozok::ActionError::MOZOK_AE_NA_ACTION;
const auto ACTION_ERROR_OTHER_ERROR = mozok::ActionError::MOZOK_OTHER_ERROR;

}

void LibMozokServer::_bind_methods() {
    // Action Status
    BIND_CONSTANT(ACTION_APPLICABLE);
    BIND_CONSTANT(ACTION_NOT_APPLICABLE);
    BIND_CONSTANT(ACTION_UNDEFINED);

    // Quest Status
    BIND_CONSTANT(QUEST_STATUS_INACTIVE);
    BIND_CONSTANT(QUEST_STATUS_DONE);
    BIND_CONSTANT(QUEST_STATUS_REACHABLE);
    BIND_CONSTANT(QUEST_STATUS_UNREACHABLE);
    BIND_CONSTANT(QUEST_STATUS_UNKNOWN);

    // Action Errors
    BIND_CONSTANT(ACTION_ERROR_NO_ERROR);
    BIND_CONSTANT(ACTION_ERROR_UNDEFINED_ACTION);
    BIND_CONSTANT(ACTION_ERROR_ARITY_ERROR);
    BIND_CONSTANT(ACTION_ERROR_UNDEFINED_OBJECT);
    BIND_CONSTANT(ACTION_ERROR_TYPE_ERROR);
    BIND_CONSTANT(ACTION_ERROR_PRECONDITIONS_ERROR);
    BIND_CONSTANT(ACTION_ERROR_NA_ACTION);
    BIND_CONSTANT(ACTION_ERROR_OTHER_ERROR);
    
    // Server Status
    ClassDB::bind_method(D_METHOD("getServerStatus"), 
            &LibMozokServer::getServerStatus);
    ClassDB::bind_method(D_METHOD("getServerStatusDescription"), 
            &LibMozokServer::getServerStatusDescription);
    ClassDB::bind_method(D_METHOD("getLastActionErrorDescription"), 
            &LibMozokServer::getLastActionErrorDescription);
    
    // Worlds
    ClassDB::bind_method(D_METHOD("createWorld", "worldName"), 
            &LibMozokServer::createWorld);
    ClassDB::bind_method(D_METHOD("deleteWorld", "worldName"), 
            &LibMozokServer::deleteWorld);
    ClassDB::bind_method(D_METHOD("hasWorld", "worldName"), 
            &LibMozokServer::hasWorld);
    ClassDB::bind_method(D_METHOD("getWorlds"), 
            &LibMozokServer::getWorlds);

    // Projects
    ClassDB::bind_method(D_METHOD(
                "addProject", "worldName", "projectFileName", "projectSrc"), 
            &LibMozokServer::addProject);
    ClassDB::bind_method(D_METHOD(
                "tryProject", "worldName", "projectFileName", "projectSrc"), 
            &LibMozokServer::tryProject);

    // Scripts
    ClassDB::bind_method(D_METHOD(
                "loadQuestScriptFile", "workingDirPath", "scriptFileName", 
                "scriptSrc", "applyInitActions"), 
            &LibMozokServer::loadQuestScriptFile);

    // Objects
    ClassDB::bind_method(D_METHOD("hasObject", "worldName", "objectName"), 
            &LibMozokServer::hasObject);
    ClassDB::bind_method(D_METHOD("getObjects", "worldName"),
            &LibMozokServer::getObjects);
    ClassDB::bind_method(D_METHOD("getObjectType", "worldName", "objectName"), 
            &LibMozokServer::getObjectType);

    // Quests
    ClassDB::bind_method(D_METHOD("hasMainQuest", "worldName", "mainQuestName"), 
            &LibMozokServer::hasMainQuest);
    ClassDB::bind_method(D_METHOD("hasSubQuest", "worldName", "subQuestName"), 
            &LibMozokServer::hasSubQuest);
    
    // Actions
    ClassDB::bind_method(D_METHOD(
                "applyAction", "worldName", "actionName", "actionArguments"),
            &LibMozokServer::applyAction);
    ClassDB::bind_method(D_METHOD(
                "pushAction", "worldName", "actionName", 
                "actionArguments", "data"), 
            &LibMozokServer::pushAction);
    ClassDB::bind_method(D_METHOD(
                "getActionStatus", "worldName", "actionName"), 
            &LibMozokServer::getActionStatus);
    ClassDB::bind_method(D_METHOD(
                "checkAction", "doNotCheckPreconditions", "worldName", 
                "actionName", "arguments"), 
            &LibMozokServer::checkAction);
    ClassDB::bind_method(D_METHOD("getActions", "worldName"), 
            &LibMozokServer::getActions);
    ClassDB::bind_method(D_METHOD("getActionType", "worldName", "actionName"), 
            &LibMozokServer::getActionType);

    // Messages
    ClassDB::bind_method(D_METHOD("processNextMessage"), 
            &LibMozokServer::processNextMessage);
    
    // Planner
    ClassDB::bind_method(D_METHOD("performPlanning"), 
            &LibMozokServer::performPlanning);

    // Worker
    ClassDB::bind_method(D_METHOD("startWorkerThread"), 
            &LibMozokServer::startWorkerThread);
    ClassDB::bind_method(D_METHOD("stopWorkerThread"), 
            &LibMozokServer::stopWorkerThread);
    
    // Saving
    ClassDB::bind_method(D_METHOD("generateSaveFile", "worldName"), 
            &LibMozokServer::generateSaveFile);

    // Message Processor Signals

    ADD_SIGNAL(MethodInfo(ON_ACTION_ERROR_SIGNAL, 
            PropertyInfo(Variant::STRING, "worldName"), 
            PropertyInfo(Variant::STRING, "actionName"),
            PropertyInfo(Variant::PACKED_STRING_ARRAY, "actionArguments"),
            PropertyInfo(Variant::STRING, "errorResult"),
            PropertyInfo(Variant::INT, "actionError"),
            PropertyInfo(Variant::INT, "data")));

    ADD_SIGNAL(MethodInfo(ON_ACTION_PUSHED_SIGNAL, 
            PropertyInfo(Variant::STRING, "worldName"), 
            PropertyInfo(Variant::STRING, "actionName"),
            PropertyInfo(Variant::PACKED_STRING_ARRAY, "actionArguments"),
            PropertyInfo(Variant::INT, "data"),
            PropertyInfo(Variant::INT, "pushStatus")));

    ADD_SIGNAL(MethodInfo(ON_NEW_MAIN_QUEST_SIGNAL, 
            PropertyInfo(Variant::STRING, "worldName"), 
            PropertyInfo(Variant::STRING, "questName")));

    ADD_SIGNAL(MethodInfo(ON_NEW_SUB_QUEST_SIGNAL, 
            PropertyInfo(Variant::STRING, "worldName"), 
            PropertyInfo(Variant::STRING, "subquestName"),
            PropertyInfo(Variant::STRING, "parentQuestName"),
            PropertyInfo(Variant::INT, "goal")));
    
    ADD_SIGNAL(MethodInfo(ON_NEW_QUEST_STATE_SIGNAL, 
            PropertyInfo(Variant::STRING, "worldName"), 
            PropertyInfo(Variant::STRING, "questName")));

    ADD_SIGNAL(MethodInfo(ON_NEW_QUEST_STATUS_SIGNAL, 
            PropertyInfo(Variant::STRING, "worldName"), 
            PropertyInfo(Variant::STRING, "questName"),
            PropertyInfo(Variant::INT, "questStatus")));

    ADD_SIGNAL(MethodInfo(ON_NEW_QUEST_GOAL_SIGNAL, 
            PropertyInfo(Variant::STRING, "worldName"), 
            PropertyInfo(Variant::STRING, "questName"),
            PropertyInfo(Variant::INT, "newGoal"),
            PropertyInfo(Variant::INT, "oldGoal")));

    ADD_SIGNAL(MethodInfo(ON_NEW_QUEST_PLAN_SIGNAL, 
            PropertyInfo(Variant::STRING, "worldName"), 
            PropertyInfo(Variant::STRING, "questName"),
            PropertyInfo(Variant::PACKED_STRING_ARRAY, "actionList"),
            PropertyInfo(Variant::ARRAY, "actionArgsList")));
    
    ADD_SIGNAL(MethodInfo(ON_SEARCH_LIMIT_REACHED_SIGNAL, 
            PropertyInfo(Variant::STRING, "worldName"), 
            PropertyInfo(Variant::STRING, "questName"),
            PropertyInfo(Variant::INT, "searchLimitValue")));
    
    ADD_SIGNAL(MethodInfo(ON_SPACE_LIMIT_REACHED_SIGNAL, 
            PropertyInfo(Variant::STRING, "worldName"), 
            PropertyInfo(Variant::STRING, "questName"),
            PropertyInfo(Variant::INT, "spaceLimitValue")));
}


// ============================== CONSTRUCTOR =============================== //

LibMozokServer::LibMozokServer() : 
    _server(mozok::Server::createServer("GDMozok", _status)) {
    // Initialize any variables here.
}


// =============================== DESTRUCTOR =============================== //

LibMozokServer::~LibMozokServer() {
    // Add your cleanup here.
}


// ================================ PROCESS ================================= //

void LibMozokServer::_process(double delta) {
    // ...
}


// ================================= UTILS ================================== //

Error LibMozokServer::resToErr(const mozok::Result& res) noexcept {
    if(res.isOk())
        return OK;
    return FAILED;
}

mozok::Str LibMozokServer::toStr(const String& str) {
    return mozok::Str(str.ascii().ptr());
}

String LibMozokServer::toString(const mozok::Str& str) {
    return String(str.c_str());
}

mozok::StrVec LibMozokServer::toStrVec(const PackedStringArray& arr) {
    mozok::StrVec res;
    for(const auto& s : arr)
        res.push_back(toStr(s));
    return res;
}

PackedStringArray LibMozokServer::toStringArr(const mozok::StrVec& arr) {
    PackedStringArray res;
    for(const auto& s : arr)
        res.push_back(toString(s));
    return res;
}


// ============================= SERVER STATUS ============================== //

Error LibMozokServer::getServerStatus() const noexcept {
    return resToErr(_status);
}

String LibMozokServer::getServerStatusDescription() const noexcept {
    return String(_status.getDescription().c_str());
}

String LibMozokServer::getLastActionErrorDescription() const noexcept {
    return String(_lastActionError.getDescription().c_str());
}


// ================================= WORLD ================================== //

Error LibMozokServer::createWorld(const String& worldName) noexcept {
    mozok::Result res = _server->createWorld(toStr(worldName));
    _status <<= res;
    return resToErr(res);
}

Error LibMozokServer::deleteWorld(const String& worldName) noexcept {
    mozok::Result res = _server->deleteWorld(toStr(worldName));
    _status <<= res;
    return resToErr(res);
}

bool LibMozokServer::hasWorld(const String& worldName) const noexcept {
    return _server->hasWorld(toStr(worldName));
}

PackedStringArray LibMozokServer::getWorlds() const noexcept {
    return toStringArr(_server->getWorlds());
}


// ================================ PROJECT ================================= //

Error LibMozokServer::addProject(
        const String& worldName,
        const String& projectFileName,
        const String& projectSrc
        ) noexcept {
    mozok::Result res = _server->addProject(
        toStr(worldName), toStr(projectFileName), toStr(projectSrc));
    _status <<= res;
    return resToErr(res);
}

Error LibMozokServer::tryProject(
        const String& worldName,
        const String& projectFileName,
        const String& projectSrc
        ) noexcept {
    mozok::Result res = _server->tryProject(
        toStr(worldName), toStr(projectFileName), toStr(projectSrc));
    _status <<= res;
    return resToErr(res);
}

// ================================ SCRIPTS ================================= //

class LibMozokServer::GDFileSystem : public mozok::FileSystem {
    const String _workingDir;
public:
    GDFileSystem(const String& workingDir) 
        : mozok::FileSystem()
        , _workingDir(workingDir)
    { /* empty */ }
    
    mozok::Result getTextFile(
            const mozok::Str& path, mozok::Str& out) noexcept override {
        String fullPath = _workingDir + toString(path);
        Ref<FileAccess> f = FileAccess::open(
                fullPath, FileAccess::ModeFlags::READ);
        if(f.is_valid() == false)
            return mozok::Result::Error(
                    "File `" + toStr(fullPath) + "` doesn't exist!");
        String res = f->get_as_text(true); // skip_cr = true
        out = toStr(res);
        return mozok::Result::OK();
    }
};

Error LibMozokServer::loadQuestScriptFile(
        const String& workingDirPath,
        const String& scriptFileName,
        const String& scriptSrc,
        bool applyInitActions
        ) noexcept {
    GDFileSystem filesystem(workingDirPath);
    mozok::Result res = _server->loadQuestScriptFile(
            &filesystem, toStr(scriptFileName), 
            toStr(scriptSrc), applyInitActions);
    _status <<= res;
    return resToErr(res);
}

// ================================ OBJECTS ================================= //

bool LibMozokServer::hasObject(
        const String& worldName,
        const String& objectName
        ) noexcept {
    return _server->hasObject(toStr(worldName), toStr(objectName));
}

PackedStringArray LibMozokServer::getObjects(
        const String& worldName
        ) const noexcept {
    return toStringArr(_server->getObjects(toStr(worldName)));
}

PackedStringArray LibMozokServer::getObjectType(
        const String& worldName,
        const String& objectName
        ) const noexcept {
    return toStringArr(
            _server->getObjectType(toStr(worldName), toStr(objectName)));
}

// ================================ OBJECTS ================================= //

bool LibMozokServer::hasMainQuest(
        const String& worldName,
        const String& mainQuestName
        ) noexcept {
    return _server->hasMainQuest(toStr(worldName), toStr(mainQuestName));
}

bool LibMozokServer::hasSubQuest(
        const String& worldName,
        const String& subQuestName
        ) noexcept {
    return _server->hasSubQuest(toStr(worldName), toStr(subQuestName));
}

// ================================ ACTIONS ================================= //

mozok::ActionError LibMozokServer::applyAction(
        const String& worldName,
        const String& actionName,
        const PackedStringArray& actionArguments
        ) noexcept {
    mozok::ActionError ae = mozok::ActionError::MOZOK_AE_NO_ERROR;
    mozok::Result res = _server->applyAction(
        toStr(worldName), toStr(actionName), 
        toStrVec(actionArguments), ae);
    if(ae != mozok::ActionError::MOZOK_AE_NO_ERROR)
        _lastActionError = res;
    return ae;
}

Error LibMozokServer::pushAction(
        const String& worldName,
        const String& actionName,
        const PackedStringArray& actionArguments,
        const int data
        ) noexcept {
    mozok::Result res = _server->pushAction(
        toStr(worldName), toStr(actionName), toStrVec(actionArguments), data);
    _status <<= res;
    emit_signal(ON_ACTION_PUSHED_SIGNAL, 
        worldName, 
        actionName,
        actionArguments,
        data,
        resToErr(res)
        );
    return resToErr(res);
}

mozok::Server::ActionStatus LibMozokServer::getActionStatus(
        const String& worldName,
        const String& actionName
        ) const noexcept {
    return _server->getActionStatus(toStr(worldName), toStr(actionName));
}

Error LibMozokServer::checkAction(
        const bool doNotCheckPreconditions,
        const String& worldName,
        const String& actionName,
        const PackedStringArray& arguments
        ) const noexcept {
    mozok::Result res = _server->checkAction(
            doNotCheckPreconditions, 
            toStr(worldName), 
            toStr(actionName),
            toStrVec(arguments));
    return resToErr(res);
}

PackedStringArray LibMozokServer::getActions(
        const String& worldName
        ) const noexcept {
    return toStringArr(_server->getActions(toStr(worldName)));
}

Array LibMozokServer::getActionType(
        const String& worldName,
        const String& actionName
        ) const noexcept {
    Array res;
    const auto r = _server->getActionType(toStr(worldName), toStr(actionName));
    for(const auto v : r)
        res.push_back(toStringArr(v));
    return res;
}

// ================================ MESSAGES ================================ //

bool LibMozokServer::processNextMessage() noexcept {
    return _server->processNextMessage(*this);
}


// ================================ PLANNER ================================= //

Error LibMozokServer::performPlanning() noexcept {
    mozok::Result res = _server->performPlanning();
    _status <<= res;
    return resToErr(res);
}


// ================================= WORKER ================================= //

Error LibMozokServer::startWorkerThread() noexcept {
    mozok::Result res = _server->startWorkerThread();
    _status <<= res;
    return resToErr(res);
}

bool LibMozokServer::stopWorkerThread() noexcept {
    return _server->stopWorkerThread();
}


// ================================= SAVING ================================= //

String LibMozokServer::generateSaveFile(const String& worldName) noexcept {
    return toString(_server->generateSaveFile(toStr(worldName)));
}


// =========================== MESSAGE PROCESSOR ============================ //

void LibMozokServer::onActionError(
        const mozok::Str& worldName, 
        const mozok::Str& actionName,
        const mozok::StrVec& actionArguments,
        const mozok::Result& errorResult,
        const mozok::ActionError actionError,
        const int data
        ) noexcept {
    emit_signal(ON_ACTION_ERROR_SIGNAL, 
        toString(worldName), 
        toString(actionName),
        toStringArr(actionArguments),
        toString(errorResult.getDescription()),
        actionError,
        data
        );
}

void LibMozokServer::onNewMainQuest(
        const mozok::Str& worldName, 
        const mozok::Str& questName
        ) noexcept {
    emit_signal(ON_NEW_MAIN_QUEST_SIGNAL, 
        toString(worldName), 
        toString(questName));
}

void LibMozokServer::onNewSubQuest(
        const mozok::Str& worldName, 
        const mozok::Str& subquestName,
        const mozok::Str& parentQuestName,
        const int goal
        ) noexcept {
    emit_signal(ON_NEW_SUB_QUEST_SIGNAL, 
        toString(worldName), 
        toString(subquestName),
        toString(parentQuestName),
        goal);
}

void LibMozokServer::onNewQuestState(
        const mozok::Str& worldName, 
        const mozok::Str& questName
        ) noexcept {
    emit_signal(ON_NEW_QUEST_STATE_SIGNAL, 
        toString(worldName), 
        toString(questName));
}

void LibMozokServer::onNewQuestStatus(
        const mozok::Str& worldName, 
        const mozok::Str& questName,
        const mozok::QuestStatus questStatus
        ) noexcept {
    emit_signal(ON_NEW_QUEST_STATUS_SIGNAL, 
        toString(worldName), 
        toString(questName),
        questStatus);
}

void LibMozokServer::onNewQuestGoal(
        const mozok::Str& worldName,
        const mozok::Str& questName,
        const int newGoal,
        const int oldGoal
        ) noexcept {
    emit_signal(ON_NEW_QUEST_GOAL_SIGNAL, 
        toString(worldName), 
        toString(questName),
        newGoal,
        oldGoal);
}

void LibMozokServer::onNewQuestPlan(
        const mozok::Str& worldName, 
        const mozok::Str& questName,
        const mozok::StrVec& actionList,
        const mozok::Vector<mozok::StrVec>& actionArgsList
        ) noexcept {
    Array args;
    for(const auto& a : actionArgsList)
        args.push_back(toStringArr(a));
    emit_signal(ON_NEW_QUEST_PLAN_SIGNAL, 
        toString(worldName), 
        toString(questName),
        toStringArr(actionList),
        args);
}

void LibMozokServer::onSearchLimitReached(
        const mozok::Str& worldName,
        const mozok::Str& questName,
        const int searchLimitValue
        ) noexcept {
    emit_signal(ON_SEARCH_LIMIT_REACHED_SIGNAL, 
        toString(worldName), 
        toString(questName),
        searchLimitValue);
}

void LibMozokServer::onSpaceLimitReached(
        const mozok::Str& worldName,
        const mozok::Str& questName,
        const int spaceLimitValue
        ) noexcept {
    emit_signal(ON_SPACE_LIMIT_REACHED_SIGNAL, 
        toString(worldName), 
        toString(questName),
        spaceLimitValue);
}
