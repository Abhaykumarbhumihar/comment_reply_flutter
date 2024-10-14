import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nested Comment Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CommentSection(),
    );
  }
}

// Data model for a comment
class Comment {
  final String author;
  final String content;
  List<Comment> replies; // Ensure it's mutable
  bool isExpanded;
  bool isReplying;

  Comment({
    required this.author,
    required this.content,
    List<Comment>? replies, // Accepting a mutable list
    this.isExpanded = false,
    this.isReplying = false,
  }) : replies = replies ?? [] { // Initialize as a mutable list if not provided
    // No need to make a copy since it's guaranteed to be mutable
  }
}

// Comment Section Widget
class CommentSection extends StatefulWidget {
  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  // Track the current active comment being replied to
  Comment? activeComment;

  // Sample comments with replies
  List<Comment> comments = [
    Comment(
      author: 'Johan',
      content: 'Apakah ini disebabkan oleh masalah mesin bus tersebut?',
    ),
    Comment(
      author: 'Jennifer',
      content: 'Sepertinya terdapat permasalahan di mesin bus tersebut',
      replies: [
        Comment(
          author: 'Jonathan',
          content: 'Terima kasih atas informasinya!',
          replies: [
            Comment(
              author: 'Alex',
              content: 'Sama-sama!',
            ),
          ],
        ),
      ],
    ),
  ];

  // Handle when the user presses the "Reply" button
  void toggleReplying(Comment comment) {
    setState(() {
      // Toggle the replying state for the selected comment, and hide others
      if (activeComment == comment) {
        activeComment = null; // Hide the reply section if clicked again
      } else {
        activeComment = comment; // Set the current comment as active
      }
    });
  }

  // Handle adding the reply to the list of replies
  void addReply(Comment comment, String replyText) {
    setState(() {
      comment.replies.add(Comment(author: 'You', content: replyText));
      comment.isReplying = false; // Hide reply box after submission
      activeComment = null; // Hide the reply text field after sending the reply
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comments')),
      body: ListView.builder(
        itemCount: comments.length,
        itemBuilder: (context, index) {
          return CommentWidget(
            comment: comments[index],
            activeComment: activeComment,
            onReply: toggleReplying,
            onSendReply: addReply,
          );
        },
      ),
    );
  }
}

// Comment Widget for displaying each comment and its replies
class CommentWidget extends StatelessWidget {
  final Comment comment;
  final int level; // Indentation level for replies
  final Function onReply;
  final Function onSendReply;
  final Comment? activeComment; // Track the current active comment

  CommentWidget({
    required this.comment,
    this.level = 0,
    required this.onReply,
    required this.onSendReply,
    required this.activeComment, // Pass the active comment state
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController replyController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.0 * level, top: 8.0, bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visualize hierarchy by increasing indentation level
              Container(
                width: 1,
                height: 50,
                color: level > 0 ? Colors.grey : Colors.transparent, // Line for replies
              ),
              SizedBox(width: 8),
              CircleAvatar(child: Text(comment.author[0])), // Avatar with author's initial
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.author,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(comment.content),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => onReply(comment), // Toggle reply text field
                          child: Text('Reply'),
                        ),
                        if (comment.replies.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              comment.isExpanded = !comment.isExpanded;
                              (context as Element).markNeedsBuild();
                            },
                            child: Text(comment.isExpanded ? 'Hide Replies' : 'View Replies'),
                          ),
                      ],
                    ),
                    if (activeComment == comment) // Show reply text field only if this is the active comment
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: replyController,
                              decoration: InputDecoration(hintText: 'Write a reply...'),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              String replyText = replyController.text;
                              if (replyText.isNotEmpty) {
                                onSendReply(comment, replyText); // Add the reply
                              }
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (comment.isExpanded)
          ...comment.replies
              .map((reply) => CommentWidget(
            comment: reply,
            level: level + 1,
            onReply: onReply,
            onSendReply: onSendReply,
            activeComment: activeComment, // Pass down the active comment
          ))
              .toList(),
      ],
    );
  }
}
