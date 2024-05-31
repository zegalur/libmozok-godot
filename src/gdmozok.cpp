#include "gdmozok.hpp"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

// ================================ BINDINGS ================================ //

namespace {

const auto ON_ACTION_ERROR_SIGNAL = "action_error";
const auto ON_NEW_MAIN_QUEST_SIGNAL = "new_main_quest";
const auto ON_NEW_SUB_QUEST_SIGNAL = "new_sub_quest";
const auto ON_NEW_QUEST_STATE_SIGNAL = "new_quest_state";
const auto ON_NEW_QUEST_STATUS_SIGNAL = "new_quest_status";
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
    
    // Server Status
    ClassDB::bind_method(D_METHOD("getServerStatus"), 
            &LibMozokServer::getServerStatus);
    ClassDB::bind_method(D_METHOD("getServerStatusDescription"), 
            &LibMozokServer::getServerStatusDescription);
    
    // Worlds
    ClassDB::bind_method(D_METHOD("createWorld", "worldName"), 
            &LibMozokServer::createWorld);
    ClassDB::bind_method(D_METHOD("deleteWorld", "worldName"), 
            &LibMozokServer::deleteWorld);
    ClassDB::bind_method(D_METHOD("hasWorld", "worldName"), 
            &LibMozokServer::hasWorld);

    // Projects
    ClassDB::bind_method(D_METHOD(
                "addProject", "worldName", "projectFileName", "projectSrc"), 
            &LibMozokServer::addProject);
    ClassDB::bind_method(D_METHOD(
                "tryProject", "worldName", "projectFileName", "projectSrc"), 
            &LibMozokServer::tryProject);
    
    // Actions
    ClassDB::bind_method(D_METHOD(
                "applyAction", "worldName", "actionName", "actionArguments"), 
            &LibMozokServer::applyAction);
    ClassDB::bind_method(D_METHOD(
                "pushAction", "worldName", "actionName", "actionArguments"), 
            &LibMozokServer::pushAction);
    ClassDB::bind_method(D_METHOD(
                "getActionStatus", "worldName", "actionName"), 
            &LibMozokServer::getActionStatus);

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
            PropertyInfo(Variant::STRING, "errorResult")));

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


// ================================= WORLD ================================== //

Error LibMozokServer::createWorld(const String& worldName) {
    mozok::Result res = _server->createWorld(toStr(worldName));
    _status <<= res;
    return resToErr(res);
}

Error LibMozokServer::deleteWorld(const String& worldName) {
    mozok::Result res = _server->deleteWorld(toStr(worldName));
    _status <<= res;
    return resToErr(res);
}

bool LibMozokServer::hasWorld(const String& worldName) const {
    return _server->hasWorld(toStr(worldName));
}


// ================================ PROJECT ================================= //

Error LibMozokServer::addProject(
        const String& worldName,
        const String& projectFileName,
        const String& projectSrc) {
    mozok::Result res = _server->addProject(
        toStr(worldName), toStr(projectFileName), toStr(projectSrc));
    _status <<= res;
    return resToErr(res);
}

Error LibMozokServer::tryProject(
        const String& worldName,
        const String& projectFileName,
        const String& projectSrc) {
    mozok::Result res = _server->tryProject(
        toStr(worldName), toStr(projectFileName), toStr(projectSrc));
    _status <<= res;
    return resToErr(res);
}


// ================================ ACTIONS ================================= //

Error LibMozokServer::applyAction(
        const String& worldName,
        const String& actionName,
        const PackedStringArray& actionArguments) {
    mozok::Result res = _server->applyAction(
        toStr(worldName), toStr(actionName), toStrVec(actionArguments));
    _status <<= res;
    return resToErr(res);
}

Error LibMozokServer::pushAction(
        const String& worldName,
        const String& actionName,
        const PackedStringArray& actionArguments) {
    mozok::Result res = _server->pushAction(
        toStr(worldName), toStr(actionName), toStrVec(actionArguments));
    _status <<= res;
    return resToErr(res);
}

mozok::Server::ActionStatus LibMozokServer::getActionStatus(
        const String& worldName,
        const String& actionName) const {
    return _server->getActionStatus(toStr(worldName), toStr(actionName));
}


// ================================ MESSAGES ================================ //

bool LibMozokServer::processNextMessage() {
    return _server->processNextMessage(*this);
}


// ================================ PLANNER ================================= //

Error LibMozokServer::performPlanning() {
    mozok::Result res = _server->performPlanning();
    _status <<= res;
    return resToErr(res);
}


// ================================= WORKER ================================= //

Error LibMozokServer::startWorkerThread() {
    mozok::Result res = _server->startWorkerThread();
    _status <<= res;
    return resToErr(res);
}

bool LibMozokServer::stopWorkerThread() {
    return _server->stopWorkerThread();
}


// ================================= SAVING ================================= //

String LibMozokServer::generateSaveFile(const String& worldName) {
    return toString(_server->generateSaveFile(toStr(worldName)));
}


// =========================== MESSAGE PROCESSOR ============================ //

void LibMozokServer::onActionError(
        const mozok::Str& worldName, 
        const mozok::Str& actionName,
        const mozok::StrVec& actionArguments,
        const mozok::Result& errorResult
        ) noexcept {
    emit_signal(ON_ACTION_ERROR_SIGNAL, 
        toString(worldName), 
        toString(actionName),
        toStringArr(actionArguments),
        toString(errorResult.getDescription()));
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