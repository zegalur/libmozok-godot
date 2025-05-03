#ifndef GDMOZOK_HPP
#define GDMOZOK_HPP

#include <godot_cpp/classes/node.hpp>
#include <libmozok/mozok.hpp>

namespace godot {

class LibMozokServer : public Node, public mozok::MessageProcessor {
    GDCLASS(LibMozokServer, Node)

private:
    mozok::Result _status;
    mozok::Result _lastActionError;
    std::unique_ptr<mozok::Server> _server;

    static Error resToErr(const mozok::Result& res) noexcept;
    static mozok::Str toStr(const String& str);
    static String toString(const mozok::Str& str);
    static mozok::StrVec toStrVec(const PackedStringArray& arr);
    static PackedStringArray toStringArr(const mozok::StrVec& arr);

    class GDFileSystem;

protected:
    static void _bind_methods();

public:
    LibMozokServer();
    ~LibMozokServer();

    void _process(double delta) override;

    // Server Status
    Error getServerStatus() const noexcept;
    String getServerStatusDescription() const noexcept;
    String getLastActionErrorDescription() const noexcept;

    // Worlds
    Error createWorld(const String& worldName) noexcept;
    Error deleteWorld(const String& worldName) noexcept;
    bool hasWorld(const String& worldName) const noexcept;
    PackedStringArray getWorlds() const noexcept;

    // Projects
    Error addProject(
        const String& worldName,
        const String& projectFileName,
        const String& projectSrc
        ) noexcept;
    Error tryProject(
        const String& worldName,
        const String& projectFileName,
        const String& projectSrc
        ) noexcept;

    // Scripts
    Error loadQuestScriptFile(
        const String& workingDirPath,
        const String& scriptFileName,
        const String& scriptSrc,
        bool applyInitActions
        ) noexcept;

    // Objects
    bool hasObject(
        const String& worldName,
        const String& objectName
        ) noexcept;
    PackedStringArray getObjects(
        const String& worldName
        ) const noexcept;
    PackedStringArray getObjectType(
        const String& worldName,
        const String& objectName
        ) const noexcept;

    // Quests
    bool hasMainQuest(
            const String& worldName,
            const String& mainQuestName
            ) noexcept;
    bool hasSubQuest(
            const String& worldName,
            const String& subQuestName
            ) noexcept;
    
    // Actions
    mozok::ActionError applyAction(
        const String& worldName,
        const String& actionName,
        const PackedStringArray& actionArguments
        ) noexcept;
    Error pushAction(
        const String& worldName,
        const String& actionName,
        const PackedStringArray& actionArguments,
        const int data
        ) noexcept;
    mozok::Server::ActionStatus getActionStatus(
        const String& worldName,
        const String& actionName
        ) const noexcept;
    Error checkAction(
        const bool doNotCheckPreconditions,
        const String& worldName,
        const String& actionName,
        const PackedStringArray& arguments
        ) const noexcept;
    PackedStringArray getActions(
        const String& worldName
        ) const noexcept;
    Array getActionType(
        const String& worldName,
        const String& actionName
        ) const noexcept;
    
    // Messages
    bool processNextMessage() noexcept;

    // Planner
    Error performPlanning() noexcept;

    // Worker
    Error startWorkerThread() noexcept;
    bool stopWorkerThread() noexcept;

    // Saving
    String generateSaveFile(const String& worldName) noexcept;

    // Message Processor
    void onActionError(
        const mozok::Str& worldName, 
        const mozok::Str& actionName,
        const mozok::StrVec& actionArguments,
        const mozok::Result& errorResult,
        const mozok::ActionError actionError,
        const int data
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
    void onNewQuestGoal(
        const mozok::Str& worldName,
        const mozok::Str& questName,
        const int newGoal,
        const int oldGoal
        ) noexcept;
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
VARIANT_ENUM_CAST(mozok::ActionError);

#endif // GDMOZOK_HPP
