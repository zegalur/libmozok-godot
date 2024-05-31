#ifndef GDMOZOK_HPP
#define GDMOZOK_HPP

#include <godot_cpp/classes/node.hpp>
#include <libmozok/mozok.hpp>
#include <memory>

namespace godot {

class LibMozokServer : public Node, public mozok::MessageProcessor {
    GDCLASS(LibMozokServer, Node)

private:
    mozok::Result _status;
    std::unique_ptr<mozok::Server> _server;

    static Error resToErr(const mozok::Result& res) noexcept;
    static mozok::Str toStr(const String& str);
    static String toString(const mozok::Str& str);
    static mozok::StrVec toStrVec(const PackedStringArray& arr);
    static PackedStringArray toStringArr(const mozok::StrVec& arr);

protected:
    static void _bind_methods();

public:
    LibMozokServer();
    ~LibMozokServer();

    void _process(double delta) override;

    // Server Status
    Error getServerStatus() const noexcept;
    String getServerStatusDescription() const noexcept;

    // Worlds
    Error createWorld(const String& worldName);
    Error deleteWorld(const String& worldName);
    bool hasWorld(const String& worldName) const;

    // Projects
    Error addProject(
        const String& worldName,
        const String& projectFileName,
        const String& projectSrc);
    Error tryProject(
        const String& worldName,
        const String& projectFileName,
        const String& projectSrc);

    // Actions
    Error applyAction(
        const String& worldName,
        const String& actionName,
        const PackedStringArray& actionArguments);
    Error pushAction(
        const String& worldName,
        const String& actionName,
        const PackedStringArray& actionArguments);
    mozok::Server::ActionStatus getActionStatus(
        const String& worldName,
        const String& actionName) const;
    
    // Messages
    bool processNextMessage();

    // Planner
    Error performPlanning();

    // Worker
    Error startWorkerThread();
    bool stopWorkerThread();

    // Saving
    String generateSaveFile(const String& worldName);

    // Message Processor
    void onActionError(
        const mozok::Str& worldName, 
        const mozok::Str& actionName,
        const mozok::StrVec& actionArguments,
        const mozok::Result& errorResult
        ) noexcept override;
    void onNewMainQuest(
        const mozok::Str& worldName, 
        const mozok::Str& questName
        ) noexcept override;
    void onNewSubQuest(
        const mozok::Str& worldName, 
        const mozok::Str& subquestName,
        const mozok::Str& parentQuestName,
        const int goal
        ) noexcept override;
    void onNewQuestState(
        const mozok::Str& worldName, 
        const mozok::Str& questName
        ) noexcept override;
    void onNewQuestStatus(
        const mozok::Str& worldName, 
        const mozok::Str& questName,
        const mozok::QuestStatus questStatus
        ) noexcept override;
    void onNewQuestPlan(
        const mozok::Str& worldName, 
        const mozok::Str& questName,
        const mozok::StrVec& actionList,
        const mozok::Vector<mozok::StrVec>& actionArgsList
        ) noexcept override;
    void onSearchLimitReached(
        const mozok::Str& worldName,
        const mozok::Str& questName,
        const int searchLimitValue
        ) noexcept override;
    void onSpaceLimitReached(
        const mozok::Str& worldName,
        const mozok::Str& questName,
        const int spaceLimitValue
        ) noexcept override;
};

}

// Register important libmozok enums.
VARIANT_ENUM_CAST(mozok::Server::ActionStatus);
VARIANT_ENUM_CAST(mozok::QuestStatus);

#endif // GDMOZOK_HPP